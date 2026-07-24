library(shiny)
library(tidyverse)
library(ggplot2)
library(maps)
library(viridis)
library(DT)

# Load raw data
movies <- read_tsv("imdb_data/title.basics.tsv.gz", 
                   col_types = cols(
                     tconst = col_character(),
                     titleType = col_character(),
                     primaryTitle = col_character(),
                     originalTitle = col_character(),
                     isAdult = col_integer(),
                     startYear = col_character(),
                     endYear = col_character(),
                     runtimeMinutes = col_character(),
                     genres = col_character()
                   ))

ratings <- read_tsv("imdb_data/title.ratings.tsv.gz", 
                    col_types = cols(
                      tconst = col_character(),
                      averageRating = col_double(),
                      numVotes = col_integer()
                    ))

names_data <- read_tsv("imdb_data/name.basics.tsv.gz", 
                       col_types = cols(
                         nconst = col_character(),
                         primaryName = col_character(),
                         birthYear = col_character(),
                         deathYear = col_character(),
                         primaryProfession = col_character(),
                         knownForTitles = col_character()
                       ))

# Clean and preprocess movie data
movies_clean <- movies %>%
  mutate(
    startYear = as.numeric(if_else(startYear == "\\N", NA_character_, startYear)),
    endYear = as.numeric(if_else(endYear == "\\N", NA_character_, endYear)),
    runtimeMinutes = as.numeric(if_else(runtimeMinutes == "\\N", NA_character_, runtimeMinutes)),
    genres = if_else(genres == "\\N", "Misc", genres),
    decade = floor(startYear / 10) * 10
  ) %>%
  filter(
    titleType %in% c("movie", "tvMovie"),
    !is.na(startYear),
    startYear >= 1900,
    startYear <= 2024
  )

# Combine movie data with ratings
movies_with_ratings <- movies_clean %>%
  inner_join(ratings, by = "tconst")

movies_genres_split <- movies_clean %>%
  separate_rows(genres, sep = ",") %>%
  mutate(is_adult_content = if_else(isAdult == 1, "Adult", "Non-Adult"))

# Find distinct genres
distinct_genres <- unique(movies_genres_split$genres)

# Calculate average rating by decade and genre
ratings_by_decade_genre <- movies_genres_split %>%
  inner_join(ratings, by = "tconst") %>%
  group_by(decade, genres) %>%
  summarize(avg_rating = mean(averageRating, na.rm = TRUE), .groups = "drop")

# Global film hubs
global_film_hubs <- data.frame(
  city = c("Hollywood", "Mumbai", "London", "Hong Kong", "Seoul",
           "Tokyo", "Lagos", "Vancouver", "Sydney", "Berlin",
           "Paris", "Cinecittà", "Chennai", "Singapore", "Cairo"),
  country = c("USA", "India", "UK", "China", "South Korea", "Japan", "Nigeria", "Canada",
              "Australia", "Germany", "France", "Italy", "India", "Singapore", "Egypt"),
  longitude = c(-118.3267, 72.8777, -0.1276, 114.1694, 126.9780, 139.7690, 3.3792,
                -123.1207, 151.2093, 13.4050, 2.3522, 12.4964, 80.2707, 103.8198, 31.2357),
  latitude = c(34.1017, 19.0760, 51.5074, 22.3193, 37.5665, 35.6804, 6.5244, 49.2827,
               -33.8688, 52.5200, 48.8566, 41.9028, 13.0827, 1.3521, 30.0444),
  annual_productions = c(600, 1500, 100, 200, 700, 1000, 2500, 500, 50, 300, 300,
                         150, 1600, 200, 50),
  industry_name = c("Hollywood", "Bollywood", "British Film Industry", "Hong Kong Cinema",
                    "Hallyuwood", "Japanese Cinema", "Nollywood", "Hollywood North",
                    "Australian Cinema", "German Cinema", "French Cinema", "Italian Cinema",
                    "Kollywood", "Singaporean Cinema", "Egyptian Cinema")
)

# Genre ratings by decade
ratings_by_decade_genre <- movies_with_ratings %>%
  separate_rows(genres, sep = ",") %>%
  filter(!is.na(genres)) %>%
  group_by(genres, decade) %>%
  summarize(avg_rating = mean(averageRating, na.rm = TRUE), .groups = 'drop') %>%
  filter(!is.na(decade))

# Genre distribution over time
genre_dist <- movies_with_ratings %>%
  separate_rows(genres, sep = ",") %>%
  count(decade, genres) %>%
  group_by(decade) %>%
  mutate(proportion = n / sum(n)) %>%
  filter(!is.na(decade))

# Names by profession
profession_trends <- names_data %>%
  separate_rows(primaryProfession, sep = ",") %>%
  mutate(
    birthYear = as.numeric(birthYear),
    primaryProfession = trimws(primaryProfession)
  ) %>%
  filter(
    !is.na(birthYear),
    birthYear >= 1990,
    !is.na(primaryProfession),
    primaryProfession != "",
    primaryProfession != "\\N"
  ) %>%
  count(birthYear, primaryProfession)

# UI
ui <- fluidPage(
  titlePanel("Exploring IMDb Data"),
  
  tabsetPanel(
    # Data Summary Tab
    tabPanel("Data Summary",
             sidebarPanel(
               h4("Data Overview"),
               selectInput("summary_var", 
                           "Choose a variable to summarize:", 
                           choices = list(
                             "Start Year" = "startYear",
                             "Runtime Minutes" = "runtimeMinutes"
                           )),
               actionButton("update_summary", "Update Summary")
             ),
             mainPanel(
               DTOutput("summary_table")
             )
    ),
    
    # Global Film Hubs Map Tab
    tabPanel("Global Film Hubs",
             sidebarPanel(
               h4("Map Controls"),
               sliderInput("hubs_size", "Filter Hubs by Production Volume:", 
                           min = min(global_film_hubs$annual_productions), 
                           max = max(global_film_hubs$annual_productions), 
                           value = c(min(global_film_hubs$annual_productions), max(global_film_hubs$annual_productions)))
             ),
             mainPanel(
               plotOutput("film_hubs_map")
             )
    ),
    
    # Ratings by Genre Tab
    tabPanel("Ratings by Genre",
             sidebarPanel(
               h4("Genre Trends"),
               checkboxGroupInput("genre_select", "Select Genres:", 
                                  choices = unique(ratings_by_decade_genre$genres),
                                  selected = NULL)  # No genres selected by default
             ),
             mainPanel(
               plotOutput("ratings_trend_plot")
             )
    ),
    
    # Heatmap of Ratings Tab
    tabPanel("Heatmap of Ratings",
             sidebarPanel(
               h4("Heatmap Settings"),
               sliderInput("decade_range", "Select Decade Range:", 
                           min = min(ratings_by_decade_genre$decade), 
                           max = max(ratings_by_decade_genre$decade), 
                           value = c(min(ratings_by_decade_genre$decade), max(ratings_by_decade_genre$decade)))
             ),
             mainPanel(
               plotOutput("heatmap_plot")
             )
    ),
    
    # Genre Distribution Tab
    tabPanel("Genre Distribution",
             sidebarPanel(
               h4("Genre Distribution"),
               checkboxGroupInput("genre_dist_select", "Select Genres to Analyze:", 
                                  choices = unique(genre_dist$genres),
                                  selected = NULL)  # No genres selected by default
             ),
             mainPanel(
               plotOutput("stacked_genre_plot")
             )
    ),
    
    # Density of Adult vs. Non-Adult Movies
    tabPanel("Density of Adult vs. Non-Adult Movies",
             sidebarPanel(
               h4("Genre Selection"),
               checkboxGroupInput("selected_genres", 
                                  "Select Genres:", 
                                  choices = NULL)  
             ),
             mainPanel(
               plotOutput("density_plot")
             )
    ),
    
    # Profession Trends Tab
    tabPanel("Profession Trends",
             sidebarPanel(
               h4("Profession Trends"),
               sliderInput("year_range", "Select Year Range:", 
                           min = min(profession_trends$birthYear), 
                           max = max(profession_trends$birthYear), 
                           value = c(min(profession_trends$birthYear), max(profession_trends$birthYear)))
             ),
             mainPanel(
               plotOutput("profession_trends_plot")
             )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Data Summary
  summary_data <- reactive({
    req(input$update_summary)
    isolate({
      movies_clean %>%
        summarise(
          min = min(!!sym(input$summary_var), na.rm = TRUE),
          max = max(!!sym(input$summary_var), na.rm = TRUE),
          mean = mean(!!sym(input$summary_var), na.rm = TRUE),
          median = median(!!sym(input$summary_var), na.rm = TRUE)
        )
    })
  })
  
  output$summary_table <- renderDT({
    datatable(summary_data(), options = list(dom = 't'))
  })
  
  # Global Film Hubs Map
  output$film_hubs_map <- renderPlot({
    filtered_hubs <- global_film_hubs %>%
      filter(annual_productions >= input$hubs_size[1] & annual_productions <= input$hubs_size[2])
    
    ggplot() +
      geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), 
                   fill = "lightgray", color = "white", linewidth = 0.1) +
      geom_point(data = filtered_hubs, aes(x = longitude, y = latitude, color = annual_productions), alpha = 0.7) +
      geom_text(data = filtered_hubs, aes(x = longitude, y = latitude, label = city), size = 3, vjust = -1, hjust = 0.5) +
      scale_color_viridis() +
      coord_fixed(1.3) +
      theme_minimal() +
      labs(title = "Major Film Production Hubs Around the World",
           subtitle = "Size and color represent the number of films produced each year",
           color = "Annual Productions")
  })
  
  # Ratings by Genre
  output$ratings_trend_plot <- renderPlot({
    req(input$genre_select)  # Ensure at least one genre is selected
    ggplot(ratings_by_decade_genre %>% filter(genres %in% input$genre_select), 
           aes(x = decade, y = avg_rating, color = genres)) +
      geom_line() + geom_point() +
      theme_minimal() +
      labs(title = "Average Movie Ratings by Genre Over Decades",
           x = "Decade", y = "Average Rating")
  })
  
  # Heatmap of Ratings by Decade
  output$heatmap_plot <- renderPlot({
    filtered_data <- ratings_by_decade_genre %>%
      filter(decade >= input$decade_range[1], decade <= input$decade_range[2])
    
    ggplot(filtered_data, aes(x = factor(decade), y = genres)) +
      geom_tile(aes(fill = avg_rating), color = "white") +
      scale_fill_viridis(option = "C", begin = 0.1, end = 0.9) +
      theme_minimal() +
      labs(title = "Average Movie Ratings by Genre and Decade",
           x = "Decade", y = "Genre", fill = "Average Rating")
  })
  
  # Genre Distribution Over Time
  output$stacked_genre_plot <- renderPlot({
    req(input$genre_dist_select)  # Ensure at least one genre is selected
    ggplot(genre_dist %>% filter(genres %in% input$genre_dist_select), 
           aes(x = decade, y = n, fill = genres)) +
      geom_col(position = "fill") +
      theme_minimal() +
      labs(title = "Movie Genre Distribution by Decade",
           x = "Decade", y = "Proportion of Total Movies", fill = "Genre")
  })
  
  # Content Distribution by Genre
  genre_count <- movies_genres_split %>%
    count(genres) %>%
    filter(n >= 10)
  
  movies_filtered <- movies_genres_split %>%
    filter(genres %in% genre_count$genres)
  
  observe({
    updateCheckboxGroupInput(
      session,
      "selected_genres",
      choices = genre_count$genres,
      selected = genre_count$genres
    )
  })
  
  output$density_plot <- renderPlot({
    req(input$selected_genres)  # Ensure at least one genre is selected
    filtered_data <- movies_filtered %>%
      filter(genres %in% input$selected_genres)
    
    ggplot(filtered_data, aes(x = is_adult_content, fill = is_adult_content)) +
      geom_density(alpha = 0.6, adjust = 1.5) +
      scale_fill_manual(values = c("Non-Adult" = "blue", "Adult" = "red")) +
      facet_wrap(~ genres, scales = "free_y") +
      labs(
        title = "Density of Adult vs. Non-Adult Movies by Genre",
        x = "Content Type",
        y = "Density",
        fill = "Content Type"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Profession Trends
  output$profession_trends_plot <- renderPlot({
    filtered_data <- profession_trends %>%
      filter(birthYear >= input$year_range[1], birthYear <= input$year_range[2])
    
    ggplot(filtered_data, aes(x = birthYear, y = n, fill = primaryProfession)) +
      geom_area(position = "fill") +
      theme_minimal() +
      labs(title = "Changing Composition of Entertainment Industry Professions",
           x = "Year", y = "Proportion of Total", fill = "Profession")
  })
}

# Run App
shinyApp(ui, server)
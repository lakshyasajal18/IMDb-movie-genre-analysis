# 🎬 IMDb Analytics Dashboard

An interactive R Shiny dashboard for exploring trends in the IMDb dataset through dynamic visualizations and user-driven analysis. The application enables users to discover patterns in movie ratings, genre popularity, film production, and industry professions across more than a century of cinema.

**Live Demo:** https://lakshyasajal18.shinyapps.io/IMDb/

---

## Features

- Interactive dashboard built with **R Shiny**
- Analyze movie ratings across genres and decades
- Explore global film production by country
- Compare genre popularity over time
- Interactive heatmap of average ratings
- Density comparison of adult vs. non-adult movies
- Profession trends across the IMDb database
- Responsive filtering with real-time visual updates

---

## Dashboard Preview

### Ratings by Genre

Compare how movie ratings have evolved across different genres over time.


<img width="1505" height="692" alt="Screenshot 2026-07-27 at 11 39 29 AM" src="https://github.com/user-attachments/assets/82d52e91-95f9-42a8-8ae1-3ad1ab0a5af9" />

---

### Heatmap of Ratings

Visualize average ratings across genres and decades using an interactive heatmap.
<img width="1505" height="509" alt="Screenshot 2026-07-27 at 11 39 41 AM" src="https://github.com/user-attachments/assets/baedd5b9-a4d5-4df2-ab4d-e65d7bdd010d" />


---

### Genre Distribution

Explore how genre popularity has shifted throughout the history of cinema.

<img width="1505" height="769" alt="Screenshot 2026-07-27 at 11 39 55 AM" src="https://github.com/user-attachments/assets/47bfd5e8-f164-42c4-8eb6-d78b6fa585a6" />


---

## Dataset

This project uses the official IMDb datasets:

- `title.basics`
- `title.ratings`
- `name.basics`

The raw datasets were cleaned, merged, and transformed into optimized `.rds` files to significantly reduce application startup time and improve deployment performance.

---

## Technologies Used

- **R**
- **Shiny**
- **ggplot2**
- **dplyr**
- **tidyr**
- **DT**
- **viridis**
- **maps**

---

## Project Structure

```text
IMDb-Dashboard/
│
├── app.R
├── prepare_data.R
├── data/
│   ├── movies_clean.rds
│   ├── movies_genres_split.rds
│   ├── ratings_by_decade_genre.rds
│   ├── genre_dist.rds
│   ├── profession_trends.rds
│   └── global_film_hubs.rds
│
├── screenshots/
│   ├── ratings-by-genre.png
│   ├── heatmap.png
│   └── genre-distribution.png
│
└── README.md
```

---

## Running Locally

Clone the repository:

```bash
git clone https://github.com/<your-username>/IMDb-Dashboard.git
cd IMDb-Dashboard
```

Open `app.R` in RStudio and run:

```r
shiny::runApp()
```

---

## Performance Optimization

To improve deployment efficiency, the application was redesigned to preprocess the IMDb datasets into serialized `.rds` files before runtime.

This optimization:

- Reduced application startup time
- Eliminated repeated preprocessing
- Improved deployment performance on shinyapps.io
- Simplified the application architecture

---

## Future Improvements

- Search by movie title
- Director and actor analytics
- Country-level filtering
- Additional interactive visualizations
- Downloadable charts and summaries

---

## Author

**Lakshya Kumar**

# Interactive IMDb Data Explorer
Interactive R Shiny dashboard for exploring the IMDb dataset through dynamic visualizations. Features analyses of movie ratings, genre trends, global film hubs, and entertainment industry professions using tidyverse, ggplot2, and Shiny.

## Dataset

This project uses IMDb's publicly available non-commercial datasets. The data files are not included in this repository due to their size.

Download the required datasets from the official IMDb website:

* IMDb Datasets: https://developer.imdb.com/non-commercial-datasets/
* Direct download folder: https://datasets.imdbws.com/

Download the following files:

* `title.basics.tsv.gz`
* `title.ratings.tsv.gz`
* `name.basics.tsv.gz`

Create a folder named `imdb_data` in the project directory and place the downloaded files inside it:

```text
project-folder/
├── app.R
└── imdb_data/
    ├── title.basics.tsv.gz
    ├── title.ratings.tsv.gz
    └── name.basics.tsv.gz
```

Then run the application with:

```r
shiny::runApp()
```

require(tidyverse)
require(tidytext)

Rcpp::sourceCpp("2_code/_helpers.cpp")
source("2_code/_helpers.R")


data = read_csv("1_data/clean/clean_data.csv")

str_words


# extract embedding -----

# process embedding
embedding = read_lines("1_data/mpnet_simcse.txt")
parts = str_split(embedding, "@@@")
nam = sapply(parts, function(x) x[1])
emb = sapply(parts, function(x) str_split(x[2],',') %>% unlist() %>% as.numeric) %>% t()
rownames(emb) = nam

# do umap -------

custom.config = umap::umap.defaults
custom.config$random_state = 3
custom.config$min_dist = .0000000001
custom.config$n_neighbors = 20
custom.config$n_components = 10
custom.config$metric = "cosine"

umap = umap::umap(emb,
                  config=custom.config)

map = umap$layout

l = 3
plot(map, xlim=c(-l, l),ylim=c(-l, l))


# do clustering -------

cl = dbscan::hdbscan(map, minPts = 5)
cl

# cl = dbscan::dbscan(map, eps = .1)
# cl

rownames(map)[cl$cluster == 3]

plot(map, col = cl$cluster+1)

# get topic tf_idf -------

topics = split(rownames(emb), cl$cluster) %>%
  sapply(function(x) str_extract_all(str_to_lower(x), "[:alpha:]+"))

outliers = topics[1]
topics_noout = topics[-1]

terms = unlist(topics) %>% unique()
term_f = table(unlist(topics))

tfidf = matrix(0,
               nrow=length(terms), ncol=length(topics_noout),
               dimnames=list(terms, names(topics_noout)))

for(i in 1:length(topics_noout)){
  topic = topics_noout[[i]]
  A = mean(lengths(topic))
  tf_tc = table(unlist(topic))
  tf_t = term_f[names(tf_tc)]
  tfidf[names(tf_tc), i] = c(tf_tc) * log(1 + (A/c(tf_t)))
  }

cluster_names = tibble(index = 1:ncol(tfidf),
       me = rownames(tfidf)[apply(tfidf, 2, which.max)],
       size = lengths(topics_noout)) %>%
  arrange(desc(size))

cluster_names

topics = split(rownames(emb), cl$cluster)[-1]
topics = topics[cluster_names$index]

names(topics) = cluster_names$me

json = jsonlite::toJSON(topics, pretty = TRUE) %>%
  jsonlite::write_json("1_data/mpnet_simcse_cluster.txt")




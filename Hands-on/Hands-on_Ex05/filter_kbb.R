library(sf)

dsn <- "Hands-on/Hands-on_Ex05/data"
layer_name <- "Batas_Wilayah_KelurahanDesa_10K_AR"

# 1. 读1行拿字段名（很快，不用等1.1GB全读完）
sample_row <- st_read(dsn, layer = layer_name,
                      query = sprintf("SELECT * FROM %s LIMIT 1", layer_name),
                      quiet = TRUE)
field_names <- names(sample_row)
cat("Fields found:\n")
print(field_names)

# 2. 自动猜测省份字段
prov_field <- field_names[grepl("PROV|PR$", field_names, ignore.case = TRUE)][1]
if (is.na(prov_field)) stop("No province-like field found, send me the printed field list")
cat("Detected province field:", prov_field, "\n")

# 3. 查含 'Bangka' 的具体写法
q_distinct <- sprintf("SELECT DISTINCT %s FROM %s WHERE %s LIKE '%%Bangka%%'",
                      prov_field, layer_name, prov_field)
distinct_vals <- st_read(dsn, query = q_distinct, quiet = TRUE)
cat("Matched province value(s):\n")
print(distinct_vals)

prov_value <- distinct_vals[[1]][1]

# 4. 按这个值筛选并读入
q_filter <- sprintf("SELECT * FROM %s WHERE %s = '%s'",
                    layer_name, prov_field, prov_value)
kbb_raw <- st_read(dsn, query = q_filter)
cat("Rows matched:", nrow(kbb_raw), "\n")

# 5. 另存为新shapefile（先去掉Z维度）
kbb_raw <- st_zm(kbb_raw, drop = TRUE, what = "ZM")
dir.create("Hands-on/Hands-on_Ex05/data/rawdata", showWarnings = FALSE)
st_write(kbb_raw, "Hands-on/Hands-on_Ex05/data/rawdata/Kepulauan_Bangka_Belitung.shp", delete_layer = TRUE)
cat("Saved to Hands-on/Hands-on_Ex05/data/rawdata/Kepulauan_Bangka_Belitung.shp\n")
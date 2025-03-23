# USDA Food Database Explorer

This repository provides tools to convert the USDA FoodData Central's full dataset into a clean, queryable SQLite database for easy offline exploration.

## 🔽 Download the Data

Before using this repository, you'll need to manually download the USDA FoodData Central full dataset from the following link:

👉 [https://fdc.nal.usda.gov/download-datasets](https://fdc.nal.usda.gov/download-datasets)

Download the **Full Download** version and extract the files to your local machine.

---

## 🧠 What This Repo Does

The Jupyter notebook file `Creating_SQLite_From_CSV_Table_Descriptions.ipynb` contains all the code needed to:

- Parse the USDA CSV files
- Clean and organize the data
- Create a SQLite database for easy querying

### 📂 Configure Your Data Folders
Inside the notebook, set your source and destination folders:

```python
# Folder with the original CSV files.
csv_folder = "FoodData_Central_csv_2024-10-31"

# Folder to store cleaned CSV files.
clean_folder = "FoodData_Central_csv_cleaned"
```

Update these variables to match the location of your extracted USDA data.

---

## 🗃️ Explore the Database

Once created, the SQLite database can be explored using your tool of choice (e.g., DB Browser for SQLite, SQLiteStudio, or programmatically in Python).

Additionally, this repo includes a pre-written `.sql` file containing a query to create a **view for percent leanness**, simplifying common nutritional queries.

---

## 🧭 Why This Exists

The USDA provides valuable data — but in disconnected, cumbersome CSV files or via a limited API.

This repo makes that data:

- Fully searchable
- Queryable with SQL
- Easier to navigate and analyze

Now you can treat the entire USDA FoodData Central dataset as a real relational database — fast, flexible, and offline.

---

## ✅ Requirements

- Python 3
- Jupyter Notebook
- `pandas`, `sqlite3` (built-in), and possibly `os`, `glob`

---

## 📜 License

This project is open-source under the [MIT License](LICENSE). It is not affiliated with or endorsed by the USDA.


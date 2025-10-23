import pandas as pd
from pathlib import Path

# Define the folder path and the output CSV file
data_dir = Path('C:/nyc_tlc_2024/nyc_tlc_2024_parquet')
output_csv = 'all_trips.csv'

# Create a list of all Parquet files in the directory
parquet_files = [parquet_file for parquet_file in data_dir.glob('*.parquet')]

# Check if any files were found
if not parquet_files:
    print(f"No parquet files found in the directory: {data_dir}")
else:
    # Use list comprehension to read each file into a DataFrame
    # Then concatenate them all into a single DataFrame
    full_df = pd.concat([pd.read_parquet(file) for file in parquet_files], ignore_index=True)

    # Write the complete DataFrame to a single CSV file
    full_df.to_csv(output_csv, index=False)
    
    print(f"Successfully combined {len(parquet_files)} parquet files into '{output_csv}'")

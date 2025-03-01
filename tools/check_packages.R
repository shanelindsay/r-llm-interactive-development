# Package Check Script
# This script checks for and installs required R packages

# List of required packages
required_packages <- c(
  # Core packages for server
  "httpuv",
  "jsonlite",
  
  # File path management
  "here",
  
  # Data manipulation and visualization
  "tidyverse",
  
  # Reporting
  "rmarkdown",
  "knitr",
  "kableExtra",
  
  # Optional but recommended packages
  "palmerpenguins", # Example dataset
  "broom",          # Model tidying
  "logger",         # Advanced logging
  "renv"            # Package management
)

# Check for missing packages
missing_packages <- required_packages[!sapply(required_packages, function(p) requireNamespace(p, quietly = TRUE))]

# Install missing packages if any
if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cran.rstudio.com/")
} else {
  cat("All required packages are installed.\n")
}

# Check package versions
cat("\nPackage versions:\n")
for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    version <- as.character(packageVersion(pkg))
    cat(sprintf("  %s: %s\n", pkg, version))
  } else {
    cat(sprintf("  %s: Not installed\n", pkg))
  }
} 
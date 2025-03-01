#!/usr/bin/env Rscript

# R JSON HTTP Server
# This script creates a persistent HTTP server that communicates using JSON

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
run_mode <- "interactive"  # Default mode
command_to_run <- NULL
port <- 8080  # Default port

# Process command line arguments
if (length(args) > 0) {
  i <- 1
  while (i <= length(args)) {
    if (args[i] == "--background" || args[i] == "-b") {
      run_mode <- "background"
      i <- i + 1
    } else if (args[i] == "--command" || args[i] == "-c") {
      if (i + 1 <= length(args)) {
        command_to_run <- args[i + 1]
        run_mode <- "command"
        i <- i + 2
      } else {
        stop("Missing command after --command|-c")
      }
    } else if (args[i] == "--port" || args[i] == "-p") {
      if (i + 1 <= length(args)) {
        port <- as.integer(args[i + 1])
        i <- i + 2
      } else {
        stop("Missing port number after --port|-p")
      }
    } else if (args[i] == "--help" || args[i] == "-h") {
      cat("Usage: Rscript r_json_server.R [options]\n")
      cat("Options:\n")
      cat("  --background, -b     Run in background mode\n")
      cat("  --command, -c CMD    Execute a single command and exit\n")
      cat("  --port, -p PORT      Specify the port (default: 8080)\n")
      cat("  --help, -h           Show this help message\n")
      quit(save = "no", status = 0)
    } else {
      warning("Unknown argument: ", args[i])
      i <- i + 1
    }
  }
}

# Check for required packages
required_packages <- c("httpuv", "jsonlite")
missing_packages <- required_packages[!sapply(required_packages, function(p) requireNamespace(p, quietly = TRUE))]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cran.rstudio.com/")
}

# Load required packages
library(httpuv)
library(jsonlite)

# Setup environment
img_dir <- "r_comm/images"
if (!dir.exists(img_dir)) {
  dir.create(img_dir, recursive = TRUE)
}

# Global variables
server <- NULL
last_call_time <- Sys.time()
heartbeat_file <- "r_comm/heartbeat.txt"
process_state_file <- "r_comm/r_process_state.txt"
process_pid_file <- "r_comm/r_process_pid.txt"

# Save PID to file
write(Sys.getpid(), process_pid_file)

# Initialize server state
server_state <- list(
  start_time = Sys.time(),
  last_call_time = Sys.time(),
  command_count = 0,
  last_command = NULL,
  last_result = NULL,
  last_error = NULL,
  r_version = R.version.string,
  pid = Sys.getpid()
)

# Write initial state to file
write("running", process_state_file)
write(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), heartbeat_file)

# Function to capture output
capture_output <- function(expr) {
  temp_output <- NULL
  temp_error <- NULL
  temp_plot <- NULL
  temp_warning <- NULL
  temp_result <- NULL
  
  # Create a connection to capture output
  output_conn <- textConnection("temp_output", "w", local = TRUE)
  error_conn <- textConnection("temp_error", "w", local = TRUE)
  
  # Redirect output and errors
  old_output <- getOption("warning.expression")
  old_sink_output <- getOption("sink.output")
  sink(output_conn, type = "output", append = TRUE)
  
  # Handle plots
  plot_index <- 1
  plot_files <- character(0)
  
  pdf(NULL) # Initialize PDF device to capture plots
  dev.control(displaylist = "enable") # Enable display list
  
  # Set up warning handler
  withCallingHandlers(
    tryCatch({
      temp_result <- eval(parse(text = expr), envir = .GlobalEnv)
      
      # Check if there are any plots to save
      if (dev.cur() > 1 && length(recordPlot()) > 0) {
        plot_file <- file.path(img_dir, paste0("plot_", format(Sys.time(), "%Y%m%d_%H%M%S_"), plot_index, ".png"))
        png(file = plot_file, width = 800, height = 600)
        replayPlot(recordPlot())
        dev.off()
        plot_files <- c(plot_files, plot_file)
        plot_index <- plot_index + 1
      }
    }, error = function(e) {
      sink(error_conn, type = "message")
      cat("Error: ", conditionMessage(e), "\n")
      sink(NULL, type = "message")
    }),
    warning = function(w) {
      temp_warning <- c(temp_warning, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  
  # Clean up
  sink(NULL) # Restore output capture
  close(output_conn)
  close(error_conn)
  dev.off() # Close the PDF device
  
  # Update heartbeat
  write(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), heartbeat_file)
  
  # Return results
  list(
    result = temp_result,
    output = paste(temp_output, collapse = "\n"),
    error = paste(temp_error, collapse = "\n"),
    warning = temp_warning,
    plots = plot_files
  )
}

# Process JSON requests
process_request <- function(req) {
  # Update last call time
  server_state$last_call_time <- Sys.time()
  write(format(server_state$last_call_time, "%Y-%m-%d %H:%M:%S"), heartbeat_file)
  
  if (req$PATH_INFO == "/status") {
    # Return server status
    list(
      status = 200L,
      headers = list('Content-Type' = 'application/json'),
      body = toJSON(list(
        status = "running",
        uptime = difftime(Sys.time(), server_state$start_time, units = "secs"),
        pid = Sys.getpid(),
        r_version = R.version.string
      ), auto_unbox = TRUE)
    )
  } else if (req$PATH_INFO == "/state") {
    # Return detailed server state
    vars <- ls(envir = .GlobalEnv)
    list(
      status = 200L,
      headers = list('Content-Type' = 'application/json'),
      body = toJSON(list(
        status = "running",
        uptime = difftime(Sys.time(), server_state$start_time, units = "secs"),
        last_call_time = format(server_state$last_call_time, "%Y-%m-%d %H:%M:%S"),
        command_count = server_state$command_count,
        variables = vars,
        last_command = server_state$last_command,
        r_version = R.version.string,
        pid = Sys.getpid()
      ), auto_unbox = TRUE)
    )
  } else if (req$PATH_INFO == "/shutdown") {
    # Shutdown the server
    write("stopped", process_state_file)
    cat("Shutting down R server\n")
    
    # Use a timer to allow the response to be sent before shutting down
    later::later(function() {
      if (!is.null(server)) {
        server$stop()
      }
      quit(save = "no")
    }, 0.5)
    
    list(
      status = 200L,
      headers = list('Content-Type' = 'application/json'),
      body = toJSON(list(status = "shutting_down"), auto_unbox = TRUE)
    )
  } else if (req$PATH_INFO == "/execute") {
    # Execute R command
    if (req$REQUEST_METHOD == "POST") {
      # Parse the JSON request body
      request_body <- rawToChar(req$rook.input$read())
      request_data <- fromJSON(request_body)
      
      if (!is.null(request_data$command)) {
        cmd <- request_data$command
        server_state$last_command <- cmd
        server_state$command_count <- server_state$command_count + 1
        
        cat("Executing: ", cmd, "\n")
        result <- capture_output(cmd)
        
        # Handle special data types for JSON serialization
        if (!is.null(result$result)) {
          # For data frames, convert to a list of lists
          if (is.data.frame(result$result)) {
            result$result_summary <- list(
              type = "data.frame",
              dim = dim(result$result),
              columns = names(result$result),
              preview = head(result$result, 10)
            )
          }
          # For models, extract summary statistics
          else if (inherits(result$result, "lm") || inherits(result$result, "glm")) {
            model_summary <- summary(result$result)
            result$result_summary <- list(
              type = class(result$result)[1],
              formula = as.character(result$result$call$formula),
              r_squared = if(inherits(result$result, "lm")) model_summary$r.squared else NULL,
              aic = if(inherits(result$result, "glm")) model_summary$aic else NULL,
              coefficients = model_summary$coefficients
            )
          }
          # For matrices, convert to summary info
          else if (is.matrix(result$result)) {
            result$result_summary <- list(
              type = "matrix",
              dim = dim(result$result),
              preview = if(all(dim(result$result) <= c(10, 10))) result$result else "Matrix too large to preview"
            )
          }
          # For large vectors, provide summary
          else if (is.vector(result$result) && length(result$result) > 100) {
            result$result_summary <- list(
              type = typeof(result$result),
              length = length(result$result),
              preview = head(result$result, 10)
            )
          }
          # For other objects, just include the class
          else {
            result$result_summary <- list(
              type = class(result$result)[1]
            )
          }
        }
        
        server_state$last_result <- result
        
        response <- list(
          status = "success",
          output = result$output,
          error = result$error,
          warning = result$warning,
          plots = result$plots,
          result_summary = result$result_summary
        )
        
        # Check for errors
        if (nchar(result$error) > 0) {
          server_state$last_error <- result$error
          response$status <- "error"
        }
        
        list(
          status = 200L,
          headers = list('Content-Type' = 'application/json'),
          body = toJSON(response, auto_unbox = TRUE, null = "null")
        )
      } else {
        list(
          status = 400L,
          headers = list('Content-Type' = 'application/json'),
          body = toJSON(list(status = "error", message = "Missing 'command' parameter"), auto_unbox = TRUE)
        )
      }
    } else {
      list(
        status = 405L,
        headers = list('Content-Type' = 'application/json'),
        body = toJSON(list(status = "error", message = "Method not allowed"), auto_unbox = TRUE)
      )
    }
  } else {
    # Unknown endpoint
    list(
      status = 404L,
      headers = list('Content-Type' = 'application/json'),
      body = toJSON(list(status = "error", message = "Endpoint not found"), auto_unbox = TRUE)
    )
  }
}

# Create the HTTP server app
app <- list(
  call = function(req) {
    process_request(req)
  },
  onWSOpen = function(ws) {
    # WebSocket support could be added here
  }
)

# Start the server
if (run_mode == "interactive" || run_mode == "background") {
  cat("Starting R JSON server on port", port, "\n")
  cat("Server PID:", Sys.getpid(), "\n")
  
  server <<- startServer("127.0.0.1", port, app)
  
  # Handle signals for clean shutdown
  if (exists("tools::.signal_interruptible")) {
    tools::.signal_interruptible(2, function(sig) {
      cat("Received interrupt signal. Shutting down...\n")
      write("stopped", process_state_file)
      if (!is.null(server)) {
        server$stop()
      }
      quit(save = "no")
    })
  }
  
  if (run_mode == "interactive") {
    # Keep the script running in interactive mode
    cat("Server is running. Press Ctrl+C to stop.\n")
    
    # Keep the process alive
    while (TRUE) {
      Sys.sleep(1)
      # Update heartbeat every 10 seconds
      if (difftime(Sys.time(), last_call_time, units = "secs") >= 10) {
        write(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), heartbeat_file)
        last_call_time <- Sys.time()
      }
    }
  } else {
    # Background mode
    cat("Server is running in background mode.\n")
    cat("To stop the server, send a request to /shutdown or kill process", Sys.getpid(), "\n")
  }
} else if (run_mode == "command") {
  # Execute a single command and exit
  cat("Executing command:", command_to_run, "\n")
  result <- capture_output(command_to_run)
  
  cat("\n=== Output ===\n")
  cat(result$output)
  
  if (nchar(result$error) > 0) {
    cat("\n=== Error ===\n")
    cat(result$error)
  }
  
  if (length(result$warning) > 0) {
    cat("\n=== Warnings ===\n")
    cat(paste(result$warning, collapse = "\n"))
  }
  
  if (length(result$plots) > 0) {
    cat("\n=== Plots saved to ===\n")
    cat(paste(result$plots, collapse = "\n"))
  }
  
  write("stopped", process_state_file)
  quit(save = "no")
} 
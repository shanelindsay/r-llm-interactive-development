#!/bin/bash

# new_project.sh - Unix/Linux version of the project creation script

# Display usage if not enough arguments provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <ProjectName> <ProjectPath>"
    echo "Example: $0 MyAnalysisProject ~/Projects"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_PATH=$2

# Ensure path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: The specified path does not exist: $PROJECT_PATH"
    exit 1
fi

FULL_PATH="$PROJECT_PATH/$PROJECT_NAME"

# Ensure project directory doesn't already exist
if [ -d "$FULL_PATH" ]; then
    echo "Error: A directory with this name already exists at: $FULL_PATH"
    exit 1
fi

# Create project from template
echo "Creating new project: $PROJECT_NAME at $FULL_PATH"
cp -r "templates/basic_project" "$FULL_PATH"

# Copy tools
if [ -d "tools" ]; then
    echo "Copying R integration tools..."
    if [ ! -d "$FULL_PATH/r_tools" ]; then
        mkdir -p "$FULL_PATH/r_tools"
    fi
    
    # Always copy core R tools that are platform-neutral
    if [ -d "tools/core" ]; then
        echo "Copying core R tools..."
        cp -r tools/core/* "$FULL_PATH/r_tools/"
    fi
    
    # Copy Unix-specific tools
    echo "Copying Unix-specific tools..."
    if [ -d "tools/unix" ]; then
        cp -r tools/unix/* "$FULL_PATH/r_tools/"
        # Make shell scripts executable
        find "$FULL_PATH/r_tools" -name "*.sh" -exec chmod +x {} \;
    fi
else
    echo "Warning: Tools directory not found. Please manually copy the R integration tools."
fi

# Update meta_log.md with current date
META_LOG_PATH="$FULL_PATH/llm_artifacts/meta_log.md"
CURRENT_DATE=$(date +"%Y-%m-%d")
if [ -f "$META_LOG_PATH" ]; then
    echo "Updating meta log with current date..."
    sed -i "s/YYYY-MM-DD/$CURRENT_DATE/g" "$META_LOG_PATH"
    sed -i "s/Project Name/$PROJECT_NAME/g" "$META_LOG_PATH"
fi

# Update README.md with project name
README_PATH="$FULL_PATH/README.md"
if [ -f "$README_PATH" ]; then
    echo "Updating README with project name..."
    sed -i "s/Project Name/$PROJECT_NAME/g" "$README_PATH"
fi

echo -e "\nProject created successfully!\n"
echo "Next steps:"
echo "1. Update the project README.md with your project description"
echo "2. Review and customize the meta_log.md file"
echo "3. Start the R server with:"
echo "   cd $FULL_PATH"
echo "   ./r_tools/rserver.sh start"
echo "   # Execute R commands with: ./r_tools/r_command.sh \"your_r_code\""
echo -e "\nHappy analysing!" 
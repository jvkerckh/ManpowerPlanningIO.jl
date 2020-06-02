function setupFile( filename::AbstractString, overwrite::Bool )

    # Add .xlsx extension if necessary.
    if !endswith( filename, ".xlsx" )
        filename = string( filename, ".xlsx" )
    end  # if !endswith( filename, ".xlsx" )

    # Ensure overwrite if file doesn't exist yet.
    if !( overwrite || ispath( filename ) )
        overwrite = true
    end  # if !( overwrite || ispath( filename ) )

    # Generate folder path if it doesn't exist.
    if !ispath( dirname( filename ) )
        mkpath( dirname( filename ) )
    end  # if !ispath( dirname( filename ) )

    return filename, overwrite
    
end  # setupFile( filename, overwrite )
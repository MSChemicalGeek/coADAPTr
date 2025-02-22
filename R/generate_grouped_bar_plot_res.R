#' Generate and Save Grouped Bar Graphs for Each Modified Residue Per Condition
#'
#' @return Grouped bar graphs for each modified residue in the data frame per condition
#' @export
#'
#' @examples generate_grouped_bar_plot_res()
#' @aliases generate_grouped_bar_plot_res
generate_grouped_bar_plot_res <- function() {
  # Prompt the user to select the Excel file
  cat("Select the Excel file containing the quantifiable residue level data: ")
  filepath <- file.choose()

  # Load the data from the selected Excel file
  df_in <- readxl::read_excel(filepath)

  # List of 10 available color palettes, including grayscale and blue-hued palette
  palettes <- list(
    "rainbow" = rainbow,
    "heat.colors" = heat.colors,
    "terrain.colors" = terrain.colors,
    "topo.colors" = topo.colors,
    "cm.colors" = cm.colors,
    "grayscale" = gray.colors,  # Grayscale palette
    "blue_hues" = function(n) colorRampPalette(c("#084594", "#2171b5", "#6baed6", "#c6dbef"))(n),  # Blue hues
    "viridis" = viridis::viridis,  # Viridis color palette
    "plasma" = viridis::plasma,    # Plasma color palette
    "inferno" = viridis::inferno   # Inferno color palette
  )

  # Function to display a preview of color palettes
  show_palette_preview <- function(palettes, num_colors = 5) {
    num_palettes <- length(palettes)
    # Adjust layout to have 2 palettes per row (to make better use of space)
    par(mfrow = c(ceiling(num_palettes / 2), 2), mar = c(1, 1, 2, 1))  # Adjust margins
    for (i in seq_along(palettes)) {
      colors <- palettes[[i]](num_colors)
      plot(1:num_colors, pch = 15, cex = 3, col = colors, xlab = "", ylab = "",
           xaxt = 'n', yaxt = 'n', bty = 'n', main = paste("Palette:", names(palettes)[i]))
    }
    par(mfrow = c(1, 1))  # Reset to default
  }

  # Ask the user if they want to see a preview of the palettes
  cat("Would you like to see a preview of the color palettes before building your plot? (yes/no): ")
  show_preview <- tolower(readline())

  if (show_preview == "yes") {
    show_palette_preview(palettes)
  }

  # Display available palettes and ask for user selection
  cat("Available color palettes:\n")
  for (i in seq_along(palettes)) {
    cat(paste0(i, ": ", names(palettes)[i], "\n"))
  }

  # Prompt user to select a palette by number
  choice <- as.numeric(readline(prompt = "Select a color palette by number: "))

  # Check if the choice is valid
  if (is.na(choice) || choice < 1 || choice > length(palettes)) {
    stop("Invalid selection. Please run the function again and select a valid option.")
  }

  # Selected palette for the bar graph
  condition_colors <- palettes[[choice]](length(unique(df_in$Condition)))

  # Prompt the user to specify the filename
  cat("Enter the new filename for the residue level data that will be saved (without extension): ")
  filename <- readline()

  # Remove any leading or trailing whitespace
  filename <- trimws(filename)

  # Arrange the dataframe by start
  df_in <- df_in %>%
    arrange(start)

  # Create a temporary column for plotting purposes - from pep
  df_in$residue_plot <- make.unique(as.character(df_in$mod_res))

  # Convert the 'peptide_plot' column to a factor based on the sorted order
  df_in$residue_plot <- factor(df_in$residue_plot, levels = df_in$residue_plot)

  # Iterate over each protein and make a grouped bar plot for it
  for (protein in unique(df_in$Sequence)) {
    # Subset the dataframe for this protein
    temp <- subset(df_in, Sequence == protein)


    # Generate a grouped bar plot of the extent of modification for each residue
    # that maps to this protein, with different conditions represented by color
    fig <- ggplot(temp, aes(x = Res, y = EOM, fill = Condition)) +
      geom_bar(position = position_dodge(width = 1), stat = "identity") +
      geom_errorbar(aes(ymin = EOM - SD, ymax = EOM + SD), position = position_dodge(width = 1), width = 0.4) +
      labs(title = paste(protein, "Residue Level Analysis"),
           x = "Residue",
           y = "Extent of Modification",
           fill = "Condition") +
      theme_classic() +
      theme(text = element_text(size = 20, family = "sans"),
            plot.title = element_text(hjust = 0.5, size = 24, family = "sans", face = "bold"),
            legend.text = element_text(size = 18, family = "sans"),
            legend.title = element_text(size = 20, family = "sans"),
            axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 1),
            axis.title.x = element_text(margin = margin(t = 22))) +
      scale_fill_manual(values = condition_colors)

    # Create the output directory for bar graphs based on the file output and excel filename
    graph_output_directory <- file.path(dirname(filepath), paste0(filename, "_ResidueLevelGroupedBarGraphs"))
    dir.create(graph_output_directory, showWarnings = FALSE, recursive = TRUE)

    # Generate the full file path for this protein and save the figure
    file_out <- file.path(graph_output_directory, paste0(protein, ".png"))
    ggsave(filename = file_out, plot = fig, device = "png", width = 12, height = 10, dpi = 1200)

    # Print a message to indicate successful saving
    cat("Grouped bar graph for", protein, "saved as", file_out, "\n")
  }
}

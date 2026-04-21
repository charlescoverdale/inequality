# make_slide_figures.R (inequality)
# Prepare slide-ready figures:
#  1. Copy the paper's hero (six-country Gini trajectories) as the hero figure
#  2. Copy the four gallery figures (Lorenz, decomposition, Atkinson, GIC)
#  3. Copy the deep-dive figure (Atkinson over aversion parameter)
#  4. Generate a QR code pointing to the paper PDF
#
# Usage:  Rscript make_slide_figures.R

suppressPackageStartupMessages({
  if (!requireNamespace("qrcode", quietly = TRUE)) {
    install.packages("qrcode", repos = "https://cloud.r-project.org")
  }
  library(qrcode)
})

fig_dir <- "figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# ------------------------------------------------------------------
# 1. Hero figure: six-country Gini trajectories from the World Bank PIP
# ------------------------------------------------------------------
src <- file.path("..", "figures", "fig6_wb_gini.pdf")
dst <- file.path(fig_dir, "hero_figure.pdf")

if (file.exists(src)) {
  file.copy(src, dst, overwrite = TRUE)
  cat("Copied hero figure to", dst, "\n")
} else {
  stop("Source figure not found: ", src,
       ". Run the paper's make_figures.R first.")
}

# ------------------------------------------------------------------
# 2. Gallery + deep-dive figures: copy the paper PDFs into slides/figures/
# ------------------------------------------------------------------
gallery <- c(
  "fig1_lorenz.pdf",     # gallery: indices via Lorenz curves
  "fig3_decompose.pdf",  # gallery: Bourguignon between-within
  "fig5_atkinson.pdf",   # gallery + deep-dive: Atkinson over aversion
  "fig4_gic.pdf"         # gallery: Ravallion-Chen growth incidence
)

for (f in gallery) {
  s <- file.path("..", "figures", f)
  d <- file.path(fig_dir, f)
  if (file.exists(s)) {
    file.copy(s, d, overwrite = TRUE)
    cat("Copied", f, "to", d, "\n")
  } else {
    warning("Missing gallery figure: ", s)
  }
}

# ------------------------------------------------------------------
# 3. QR code to the paper PDF on the publications page
# ------------------------------------------------------------------
paper_url <- "https://charlescoverdale.github.io/files/coverdale_inequality_2026.pdf"

qr <- qr_code(paper_url, ecl = "M")
png(
  filename = file.path(fig_dir, "qrcode_paper.png"),
  width = 800, height = 800, res = 300, bg = "white"
)
par(mar = rep(0, 4))
plot(qr)
dev.off()

cat("QR code written to", file.path(fig_dir, "qrcode_paper.png"), "\n")

# Figure generator for the inequality R Journal paper.
#
# Produces five PDF figures and one LaTeX table under paper/figures/ and
# paper/tables/. Run from the package root with:
#   RSTUDIO_PANDOC=/Applications/quarto/bin/tools Rscript paper/make_figures.R

suppressPackageStartupMessages({
  devtools::load_all(".", quiet = TRUE)
  library(ggplot2)
  library(showtext)
})

font_add("HelveticaNeue",
         regular = "/System/Library/Fonts/Helvetica.ttc",
         bold = "/System/Library/Fonts/Helvetica.ttc",
         italic = "/System/Library/Fonts/Helvetica.ttc")
showtext_auto()
showtext_opts(dpi = 300)

fig_dir <- "paper/figures"
tab_dir <- "paper/tables"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)
if (!dir.exists(tab_dir)) dir.create(tab_dir, recursive = TRUE)

ok_blue   <- "#0072B2"
ok_orange <- "#E69F00"
ok_green  <- "#009E73"
ok_red    <- "#D55E00"
ok_purple <- "#CC79A7"
ok_yellow <- "#F0E442"
ok_sky    <- "#56B4E9"

fam <- "HelveticaNeue"

theme_wp <- function(base_size = 10) {
  theme_bw(base_size = base_size, base_family = fam) +
    theme(
      plot.title = element_blank(),
      plot.subtitle = element_blank(),
      plot.caption = element_blank(),
      panel.border = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(linewidth = 0.25, colour = "grey85"),
      axis.line = element_line(linewidth = 0.35, colour = "grey25"),
      axis.ticks = element_line(linewidth = 0.35, colour = "grey25"),
      axis.ticks.length = unit(2.5, "pt"),
      axis.text = element_text(size = base_size, colour = "grey20"),
      axis.title = element_text(size = base_size, colour = "grey20"),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = base_size - 1, family = fam),
      legend.key.height = unit(10, "pt"),
      legend.key.width = unit(22, "pt"),
      legend.spacing.x = unit(10, "pt"),
      legend.margin = margin(4, 0, 0, 0),
      plot.margin = margin(6, 10, 6, 6)
    )
}

tex_esc <- function(x) gsub("_", "\\\\_", as.character(x))

# -----------------------------------------------------------------------------
# Figure 1: Lorenz curves for three income distributions.
# -----------------------------------------------------------------------------
set.seed(20260418)
n <- 2000
# Three distributions with deliberately different Gini coefficients.
inc_low <- rlnorm(n, meanlog = 10.5, sdlog = 0.35)     # Gini ~ 0.20
inc_mid <- rlnorm(n, meanlog = 10.5, sdlog = 0.80)     # Gini ~ 0.42
inc_hi  <- rlnorm(n, meanlog = 10.5, sdlog = 1.40)     # Gini ~ 0.63

L_low <- iq_lorenz(inc_low)
L_mid <- iq_lorenz(inc_mid)
L_hi  <- iq_lorenz(inc_hi)

df_lor <- rbind(
  data.frame(pop = L_low$curve$cum_pop, inc = L_low$curve$cum_income,
             series = sprintf("Low inequality (Gini = %.2f)", L_low$gini)),
  data.frame(pop = L_mid$curve$cum_pop, inc = L_mid$curve$cum_income,
             series = sprintf("Medium inequality (Gini = %.2f)", L_mid$gini)),
  data.frame(pop = L_hi$curve$cum_pop,  inc = L_hi$curve$cum_income,
             series = sprintf("High inequality (Gini = %.2f)", L_hi$gini))
)
df_lor$series <- factor(df_lor$series,
                        levels = c(sprintf("Low inequality (Gini = %.2f)", L_low$gini),
                                   sprintf("Medium inequality (Gini = %.2f)", L_mid$gini),
                                   sprintf("High inequality (Gini = %.2f)", L_hi$gini)))

p1 <- ggplot(df_lor, aes(x = pop, y = inc,
                         colour = series, linetype = series)) +
  geom_abline(slope = 1, intercept = 0,
              colour = "grey60", linewidth = 0.35, linetype = "dashed") +
  geom_line(linewidth = 0.7) +
  scale_colour_manual(values = c(ok_green, ok_blue, ok_red)) +
  scale_linetype_manual(values = c("solid", "longdash", "dotted")) +
  scale_x_continuous(limits = c(0, 1), expand = c(0, 0),
                     labels = scales::percent_format(accuracy = 1)) +
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0),
                     labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Cumulative population share",
       y = "Cumulative income share") +
  guides(colour = guide_legend(nrow = 3),
         linetype = guide_legend(nrow = 3)) +
  coord_fixed() +
  theme_wp(base_size = 10)

ggsave(file.path(fig_dir, "fig1_lorenz.pdf"),
       p1, width = 5.0, height = 4.2, device = cairo_pdf)

cat(sprintf("fig1: Ginis = %.3f / %.3f / %.3f\n",
            L_low$gini, L_mid$gini, L_hi$gini))

# -----------------------------------------------------------------------------
# Figure 2: Gini with Davidson 95% CI across sample sizes.
# -----------------------------------------------------------------------------
set.seed(20260418)
ns <- c(100, 250, 500, 1000, 2500, 5000)
reps <- 40  # independent draws at each n
fig2_rows <- list()
for (nn in ns) {
  for (r in seq_len(reps)) {
    x <- rlnorm(nn, meanlog = 10.5, sdlog = 0.8)
    g <- iq_gini(x, ci = TRUE, method = "bootstrap", R = 400)
    fig2_rows[[length(fig2_rows) + 1L]] <- data.frame(
      n = nn, rep = r,
      gini = g$gini, lower = g$ci_lower, upper = g$ci_upper
    )
  }
}
df2 <- do.call(rbind, fig2_rows)
df2$width <- df2$upper - df2$lower
df_sum2 <- aggregate(cbind(gini, width) ~ n, data = df2, FUN = mean)

p2 <- ggplot(df_sum2, aes(x = n, y = width)) +
  geom_line(colour = ok_blue, linewidth = 0.7) +
  geom_point(colour = ok_blue, size = 2) +
  scale_x_log10() +
  scale_y_continuous(limits = c(0, max(df_sum2$width) * 1.15),
                     expand = c(0, 0)) +
  labs(x = "Sample size (log scale)",
       y = "Mean 95% CI width (Davidson bootstrap)") +
  theme_wp(base_size = 10)

ggsave(file.path(fig_dir, "fig2_gini_ci.pdf"),
       p2, width = 5.5, height = 3.2, device = cairo_pdf)

cat(sprintf("fig2: CI width at n=100 = %.3f, at n=5000 = %.3f\n",
            df_sum2$width[df_sum2$n == 100],
            df_sum2$width[df_sum2$n == 5000]))

# -----------------------------------------------------------------------------
# Figure 3: Bourguignon between-within decomposition.
# -----------------------------------------------------------------------------
set.seed(20260418)
# Construct three grouping scenarios with the same total inequality but
# different between-group share.
n_grp <- 1500
# Scenario A: small between-group difference.
meanA <- rep(c(30000, 32000, 34000), length.out = n_grp)
inc_A <- meanA * exp(rnorm(n_grp, sd = 0.6))
grp_A <- rep(c("G1", "G2", "G3"), length.out = n_grp)
# Scenario B: moderate between-group difference.
meanB <- rep(c(25000, 35000, 55000), length.out = n_grp)
inc_B <- meanB * exp(rnorm(n_grp, sd = 0.6))
grp_B <- rep(c("G1", "G2", "G3"), length.out = n_grp)
# Scenario C: large between-group difference.
meanC <- rep(c(18000, 40000, 80000), length.out = n_grp)
inc_C <- meanC * exp(rnorm(n_grp, sd = 0.6))
grp_C <- rep(c("G1", "G2", "G3"), length.out = n_grp)

decA <- iq_decompose(inc_A, grp_A, index = "T")
decB <- iq_decompose(inc_B, grp_B, index = "T")
decC <- iq_decompose(inc_C, grp_C, index = "T")

df3 <- rbind(
  data.frame(scenario = "Small group gap",    component = "Between", value = decA$between),
  data.frame(scenario = "Small group gap",    component = "Within",  value = decA$within),
  data.frame(scenario = "Moderate group gap", component = "Between", value = decB$between),
  data.frame(scenario = "Moderate group gap", component = "Within",  value = decB$within),
  data.frame(scenario = "Large group gap",    component = "Between", value = decC$between),
  data.frame(scenario = "Large group gap",    component = "Within",  value = decC$within)
)
df3$scenario <- factor(df3$scenario,
                       levels = c("Small group gap",
                                  "Moderate group gap",
                                  "Large group gap"))
df3$component <- factor(df3$component, levels = c("Within", "Between"))

p3 <- ggplot(df3, aes(x = scenario, y = value, fill = component)) +
  geom_col(width = 0.55) +
  scale_fill_manual(values = c("Within" = ok_sky, "Between" = ok_red)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(x = NULL, y = "Theil T (GE(1)) index") +
  guides(fill = guide_legend(nrow = 1)) +
  theme_wp(base_size = 10)

ggsave(file.path(fig_dir, "fig3_decompose.pdf"),
       p3, width = 5.5, height = 3.2, device = cairo_pdf)

cat(sprintf("fig3: A between share %.1f%%, C between share %.1f%%\n",
            100 * decA$between / decA$total,
            100 * decC$between / decC$total))

# -----------------------------------------------------------------------------
# Figure 4: Ravallion-Chen growth incidence curve.
# -----------------------------------------------------------------------------
set.seed(20260418)
panel <- iq_sample_data("panel")
gic <- iq_growth_incidence(panel$income_t0, panel$income_t1,
                           n_quantiles = 20)
df4 <- gic$gic
df4$pct <- 100 * df4$quantile

p4 <- ggplot(df4, aes(x = pct, y = growth)) +
  geom_hline(yintercept = gic$mean_growth, linewidth = 0.35,
             colour = "grey50", linetype = "dashed") +
  geom_line(colour = ok_blue, linewidth = 0.7) +
  geom_point(colour = ok_blue, size = 1.8) +
  annotate("text",
           x = 12, y = gic$mean_growth,
           label = sprintf("mean growth = %.1f%%", 100 * gic$mean_growth),
           vjust = -0.6, hjust = 0, size = 3.1, family = fam,
           colour = "grey20") +
  scale_x_continuous(limits = c(0, 100), expand = c(0, 0),
                     breaks = seq(0, 100, 20)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Income percentile",
       y = "Annualised income growth") +
  theme_wp(base_size = 10)

ggsave(file.path(fig_dir, "fig4_gic.pdf"),
       p4, width = 5.5, height = 3.2, device = cairo_pdf)

cat(sprintf("fig4: bottom decile growth %.1f%%, top decile %.1f%%\n",
            100 * df4$growth[1],
            100 * tail(df4$growth, 1)))

# -----------------------------------------------------------------------------
# Figure 5: Index sensitivity — Atkinson over inequality aversion epsilon.
# -----------------------------------------------------------------------------
set.seed(20260418)
# Two distributions with similar Gini but different tail shapes: one
# lognormal, one mixture with a heavy right tail.
n5 <- 3000
inc_ln  <- rlnorm(n5, meanlog = 10.5, sdlog = 0.75)
# Mixture: 85% moderate lognormal + 15% very heavy top tail.
inc_mx  <- c(rlnorm(0.85 * n5, 10.3, 0.55),
             rlnorm(0.15 * n5, 11.8, 1.10))

epsilons <- seq(0.1, 2.5, by = 0.1)
df5 <- do.call(rbind, lapply(epsilons, function(e) {
  rbind(
    data.frame(epsilon = e, series = "Lognormal",
               atkinson = iq_atkinson(inc_ln, epsilon = e)$value),
    data.frame(epsilon = e, series = "Heavy-tailed mixture",
               atkinson = iq_atkinson(inc_mx, epsilon = e)$value)
  )
}))
df5$series <- factor(df5$series,
                     levels = c("Lognormal", "Heavy-tailed mixture"))

p5 <- ggplot(df5, aes(x = epsilon, y = atkinson,
                      colour = series, linetype = series)) +
  geom_line(linewidth = 0.7) +
  scale_colour_manual(values = c(ok_blue, ok_red)) +
  scale_linetype_manual(values = c("solid", "longdash")) +
  scale_x_continuous(limits = c(0, 2.6), expand = c(0, 0),
                     breaks = seq(0, 2.5, 0.5)) +
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
  labs(x = expression("Inequality aversion " * epsilon),
       y = "Atkinson index") +
  guides(colour = guide_legend(nrow = 1),
         linetype = guide_legend(nrow = 1)) +
  theme_wp(base_size = 10)

ggsave(file.path(fig_dir, "fig5_atkinson.pdf"),
       p5, width = 5.5, height = 3.2, device = cairo_pdf)

g_ln <- iq_gini(inc_ln)$gini
g_mx <- iq_gini(inc_mx)$gini
cat(sprintf("fig5: Gini lognormal %.3f, Gini mixture %.3f\n", g_ln, g_mx))

# -----------------------------------------------------------------------------
# Figure 6: World Bank Gini time series, six countries 1970-2024.
# -----------------------------------------------------------------------------
wb <- read.csv("paper/data/wdi_gini.csv", stringsAsFactors = FALSE)
keep <- c("USA", "GBR", "FRA", "DEU", "SWE", "BRA")
wb <- wb[wb$iso3 %in% keep & wb$year >= 1970, ]
wb$country <- factor(wb$country, levels = c(
  "Sweden", "Germany", "France", "United Kingdom",
  "United States", "Brazil"))

p6 <- ggplot(wb, aes(x = year, y = gini,
                      colour = country, linetype = country,
                      shape = country)) +
  geom_line(linewidth = 0.55, alpha = 0.9) +
  geom_point(size = 1.6, alpha = 0.85) +
  scale_colour_manual(values = c(
    Sweden = ok_blue, Germany = ok_green, France = ok_sky,
    `United Kingdom` = ok_purple, `United States` = ok_red,
    Brazil = ok_orange)) +
  scale_linetype_manual(values = c(
    Sweden = "solid", Germany = "longdash", France = "dotted",
    `United Kingdom` = "dotdash", `United States` = "solid",
    Brazil = "longdash")) +
  scale_shape_manual(values = c(
    Sweden = 16, Germany = 17, France = 15,
    `United Kingdom` = 18, `United States` = 16, Brazil = 17)) +
  scale_x_continuous(breaks = seq(1970, 2020, 10)) +
  scale_y_continuous(limits = c(20, 65)) +
  labs(x = NULL, y = "Gini coefficient (World Bank, PovcalNet)") +
  guides(colour = guide_legend(nrow = 2,
                               override.aes = list(linewidth = 0.8)),
         linetype = guide_legend(nrow = 2),
         shape = guide_legend(nrow = 2)) +
  theme_wp(base_size = 10)

ggsave(file.path(fig_dir, "fig6_wb_gini.pdf"),
       p6, width = 5.5, height = 3.4, device = cairo_pdf)

cat(sprintf("fig6: %d obs across %d countries\n",
            nrow(wb), length(unique(wb$iso3))))

# -----------------------------------------------------------------------------
# Table: country-level summary of WB Gini coverage + first/last/change.
# -----------------------------------------------------------------------------
wb_summary <- do.call(rbind, lapply(split(wb, wb$country), function(g) {
  g <- g[order(g$year), ]
  data.frame(
    country = g$country[1],
    first_year = min(g$year),
    first_gini = g$gini[1],
    last_year  = max(g$year),
    last_gini  = g$gini[nrow(g)],
    change     = g$gini[nrow(g)] - g$gini[1],
    n_obs      = nrow(g)
  )
}))

tab_lines2 <- c(
  "\\begin{tabular}{lrrrrr}",
  "\\toprule",
  "Country & First & First Gini & Last & Last Gini & Change (pp) \\\\",
  "\\midrule"
)
# Order: by last Gini ascending (lowest inequality first).
wb_summary <- wb_summary[order(wb_summary$last_gini), ]
for (i in seq_len(nrow(wb_summary))) {
  r <- wb_summary[i, ]
  tab_lines2 <- c(tab_lines2,
    sprintf("%s & %d & %.1f & %d & %.1f & %+.1f \\\\",
            tex_esc(as.character(r$country)),
            r$first_year, r$first_gini,
            r$last_year, r$last_gini, r$change))
}
tab_lines2 <- c(tab_lines2, "\\bottomrule", "\\end{tabular}")
writeLines(tab_lines2, file.path(tab_dir, "wb_summary.tex"))

# -----------------------------------------------------------------------------
# Table: iq_compare() output for the canonical sample.
# -----------------------------------------------------------------------------
d_comp <- iq_sample_data("income")
cmp <- iq_compare(d_comp$income, ci = TRUE, R = 400)
tab_df <- cmp$table

tab_lines <- c(
  "\\begin{tabular}{lr}",
  "\\toprule",
  "Index & Value \\\\",
  "\\midrule"
)
for (i in seq_len(nrow(tab_df))) {
  tab_lines <- c(tab_lines,
    sprintf("%s & %.4f \\\\",
            tex_esc(tab_df$measure[i]),
            as.numeric(tab_df$value[i])))
}
tab_lines <- c(tab_lines, "\\bottomrule", "\\end{tabular}")
writeLines(tab_lines, file.path(tab_dir, "compare.tex"))

cat("\n--- done ---\n")

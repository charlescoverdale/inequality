---
output: pdf_document
fontsize: 12pt
---

\thispagestyle{empty}
\today

The Editor
The R Journal
\bigskip

Dear Editor,
\bigskip

Please consider the article *Inequality: Inequality Measurement, Decomposition, and Poverty Analysis in R* for publication in the R Journal.

The article introduces the `inequality` package, a comprehensive R implementation of the indices, decompositions, poverty measures, and redistribution diagnostics routinely used in applied distributional economics. The main existing CRAN package, `ineq`, has not been updated since 2014: it covers the Gini and Theil indices and renders a Lorenz curve, but has no support for survey weights, no confidence intervals, no between-within decomposition, no poverty measures, no Palma ratio, no tax progressivity, and no concentration indices. Applied work has filled the gap with ad hoc scripts that are neither tested nor cited. The `inequality` package consolidates every index, decomposition, poverty measure, and fiscal-redistribution diagnostic in a single package with a uniform interface, Davidson (2009) confidence intervals for the Gini, Bourguignon (1979) decomposition, Ravallion-Chen (2003) growth incidence curves, Kakwani progressivity, and Wolfson polarisation. Every function accepts optional survey weights and returns a cited S3 object.

Readers of the R Journal who work in distributional economics, public-finance analysis, development economics, labour economics, or health-inequality measurement will find an immediate use for the package. Two case studies illustrate its coverage: a comparison of the Atkinson index across inequality-aversion parameters for two synthetic distributions (showing how the ordinal inequality ranking can depend on the chosen index), and a pipeline over the World Bank Poverty and Inequality Platform Gini series for six economies from 1970 to 2024.

The manuscript has not been published in a peer-reviewed journal, is not currently under review elsewhere, and all rights to submit rest with the sole author.

\bigskip
\bigskip

Regards,
\bigskip
\bigskip

Charles Coverdale
London, United Kingdom
charles.f.coverdale@gmail.com

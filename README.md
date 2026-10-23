# shubhankarlondhe.github.io

Personal academic website of Shubhankar Londhe, built with [Quarto](https://quarto.org). Live at <https://shubhankarlondhe.github.io>.

## Branches

- `main`: the published site. Every push to `main` runs the `Publish site` GitHub Action, which renders the site and deploys it to GitHub Pages.
- `dev`: work in progress. Pushes to `dev` are rendered as a check but not published. Open a pull request from `dev` into `main` to publish.

## Where to edit content

| What | File |
| --- | --- |
| Bio, photo, social links | `index.qmd` |
| Publications (website and CV) | `data/publications.bib` |
| Code / project cards | `projects.qmd` |
| CV (website page and both PDFs) | `data/cv.yml` |
| Teaching | `teaching.qmd` |
| Navigation bar, site title, footer | `_quarto.yml` |
| Colours and fonts | `styles.scss` |

## Local preview

```bash
make site      # CV PDFs, then the site
quarto preview
```

## CV

`data/cv.yml` and `data/publications.bib` are the single source for the CV page, the Publications page and two PDFs, rendered with Typst by `_cv/cv.lua`:

```bash
make cv        # assets/cv/cv-academic.pdf and assets/cv/cv-industry.pdf
```

Section order for each version is set under `layouts:` in `data/cv.yml`. The PDFs are not committed; the GitHub Action builds them on every deploy.

The site has no executable code, so it needs only Quarto (no Python or R environment). Python code cells would work too, but the GitHub Action would then need a Python setup step.

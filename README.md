# shubhankarlondhe.github.io

Personal academic website of Shubhankar Londhe, built with [Quarto](https://quarto.org). Live at <https://shubhankarlondhe.github.io>.

## Branches

- `main`: the published site. Every push to `main` runs the `Publish site` GitHub Action, which renders the site and deploys it to GitHub Pages.
- `dev`: work in progress. Pushes to `dev` are rendered as a check but not published. Open a pull request from `dev` into `main` to publish.

## Where to edit content

| What | File |
| --- | --- |
| Bio, photo, social links | `index.qmd` |
| Publications | `publications.qmd` |
| Code / project cards | `projects.qmd` |
| CV (education, talks, awards) | `cv.qmd` |
| Teaching | `teaching.qmd` |
| Navigation bar, site title, footer | `_quarto.yml` |
| Colours and fonts | `styles.scss` |

## Local preview

```bash
quarto preview
```

The site has no executable code, so it needs only Quarto (no Python or R environment). Python code cells would work too, but the GitHub Action would then need a Python setup step.

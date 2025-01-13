module.exports = {
  "*.ts": [
    "eslint --fix"
  ],
  "*.{ts,scss,html,json}": [
    "prettier --write"
  ]
};

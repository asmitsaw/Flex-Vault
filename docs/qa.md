# Quality Assurance

## Security Validation

- Penetration Tests: Not yet performed.
- Vulnerability Scanning: Recommend enabling Amazon Inspector for Lambda and containerized assets; use `npm audit` for backend dependencies.
- Compliance: No certifications yet; plan for SOC 2 Type II and ISO/IEC 27001 alignment.

## ML Feature Testing

- Current accuracy metrics: Not available; client-side ML Kit only.
- Proposed metrics: classification accuracy, OCR precision/recall, drift detection via embedding distribution monitoring.

## Search Validation

- Query response times: N/A (search not implemented).
- Recall/precision: N/A.
- User satisfaction: Collect via in-app feedback once search is available.

## Cross-browser Testing

- Frontend is Flutter; target platforms are mobile and desktop apps.
- Web build available (`web/`), recommended browser matrix: Chrome, Edge, Firefox, Safari latest two versions.


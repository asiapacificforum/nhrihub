FactoryGirl.define do
  factory :csp_report do
    document_uri { "http://localhost:3000/en/login"}
    referrer {  "http://localhost:3000/en/dashboard/index" }
    violated_directive { "default-src https: 'self'" }
    effective_directive { "script-src"}
    source_file { "string"}
    original_policy { "default-src https: 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' 'nonce-sntJzNwglklLZC2ydV0DbBSdEbAVUyph8CKjdkevyJY='; style-src 'self' 'unsafe-inline' 'nonce-sntJzNwglklLZC2ydV0DbBSdEbAVUyph8CKjdkevyJY='; report-uri /en/csp_reports" }
    blocked_uri { "inline" }
    status_code { 200 }
    line_number { 57 }
  end
end


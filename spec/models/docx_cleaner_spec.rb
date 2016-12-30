require_relative '../../app/domain_models/docx_cleaner.rb'
describe "consolidate double opening braces" do
  it "should eliminate all xml between double open braces" do
    xml = '<w:t>{</w:t></w:r><w:proofErr w:type="gramStart"/><w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/></w:rPr><w:t>{</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_open_braces).to eq "<w:t>{{</w:t>"
  end

  it "should not change already consolidated double braces" do
    xml = "<w:t>{{</w:t>"
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_open_braces).to eq "<w:t>{{</w:t>"
  end

  it "should not perform greedy searches" do
    xml = '<w:t>{</w:t></w:r><w:proofErr w:type="gramStart"/><w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/></w:rPr><w:t>{</w:t>'
    xml += xml
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_open_braces).to eq "<w:t>{{</w:t><w:t>{{</w:t>"
  end

  it "should eliminate all xml between double open braces" do
    xml = '<w:t xml:space="preserve"> {</w:t></w:r><w:proofErr w:type="gramStart"/><w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/></w:rPr><w:t>{ </w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_open_braces).to eq "<w:t>{{</w:t>"
  end
end

describe "consolidate double closing braces" do
  it "should eliminate all xml between double open braces" do
    xml = '<w:t xml:space="preserve"> }</w:t></w:r><w:proofErr w:type="gramStart"/><w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/></w:rPr><w:t>} </w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_close_braces).to eq "<w:t>}}</w:t>"
  end

  it "should not change already consolidated double braces" do
    xml = "<w:t>}}</w:t>"
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_close_braces).to eq "<w:t>}}</w:t>"
  end

  it "should not perform greedy searches" do
    xml = '<w:t>}</w:t></w:r><w:proofErr w:type="gramStart"/><w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/></w:rPr><w:t>}</w:t>'
    xml += xml
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate_double_close_braces).to eq "<w:t>}}</w:t><w:t>}}</w:t>"
  end
end

describe "consolidate text nodes" do
  it "should consolidate all text nodes between moustache delimiters" do
    xml = '<w:t>{{</w:t><w:t>da</w:t>some stuff <w:t>ta</w:t> more stuff  <w:t>base</w:t> <w:t>}}</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:t>{{database}}</w:t>"
  end

  it "should consolidate all text nodes between moustache delimiters when text nodes contain spaces" do
    xml = '<w:t>{{</w:t><w:t xml:space="preserve">da </w:t><w:t>ta</w:t><w:t>base</w:t> <w:t>}}</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:t>{{da tabase}}</w:t>"
  end

  it "should leave intact text nodes outside of moustache delimiters" do
    xml = '<w:t>text here</w:t><w:t>{{</w:t><w:t>da</w:t><w:t>ta</w:t><w:t>base</w:t> <w:t>}}</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:t>text here</w:t><w:t>{{database}}</w:t>"
  end

  it "should ignore xml attributes" do
    xml = '<w:tc><w:p><w:r><w:t xml:space="preserve"> {</w:t></w:r><w:r><w:t>{ </w:t></w:r><w:r><w:t xml:space="preserve"> date</w:t></w:r><w:r w:rsidR="00D046BB"><w:t xml:space="preserve"> </w:t></w:r><w:r><w:t>}}</w:t></w:r></w:p>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:tc><w:p><w:r><w:t>{{ date }}</w:t></w:r></w:p>"
  end
end

describe "consolidate" do
  it "should consolidate all moustache strings" do
    xml = '<w:t xml:space="preserve"> {</w:t><w:t>{</w:t><w:t>da</w:t>some stuff <w:t>ta</w:t> more stuff  <w:t>base</w:t> <w:t>}</w:t><w:t>}</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:t>{{database}}</w:t>"
  end
end

describe "consolidate" do
  it "should consolidate all moustache strings" do
  xml = '<w:r><w:t>{</w:t></w:r><w:r><w:t xml:space="preserve">{ </w:t></w:r><w:r><w:t>complainant</w:t></w:r><w:r><w:t>_full_name</w:t></w:r><w:r><w:t xml:space="preserve"> }}</w:t></w:r></w:p></w:tc><w:tc><w:p><w:r><w:t>Name:</w:t></w:r></w:p></w:tc><w:tc><w:p><w:r><w:t xml:space="preserve">{{ </w:t></w:r><w:r><w:t>witness_name</w:t></w:r><w:r><w:t xml:space="preserve"> }}</w:t></w:r>'
  dc = DocxCleaner.new(xml)
  expect(dc.consolidate).to eq "<w:r><w:t>{{complainant_full_name }}</w:t></w:r></w:p></w:tc><w:tc><w:p><w:r><w:t>Name:</w:t></w:r></w:p></w:tc><w:tc><w:p><w:r><w:t>{{ witness_name }}</w:t></w:r>"
  end

  it "should leave intact all well-formed moustache strings" do
  xml = '<w:t>{{ text }}</w:t>'
  dc = DocxCleaner.new(xml)
  expect(dc.consolidate).to eq "<w:t>{{ text }}</w:t>"
  end

  it "should consolidate partially well-formed strings" do
    xml = '<w:t>{{ text</w:t><w:t> }}</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:t>{{ text }}</w:t>"
  end

  it "should consolidate partially well-formed strings" do
    xml = '<w:t>{{</w:t><w:t> text }}</w:t>'
    dc = DocxCleaner.new(xml)
    expect(dc.consolidate).to eq "<w:t>{{ text }}</w:t>"
  end
end

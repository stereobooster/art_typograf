# encoding: utf-8
require 'art_typograf'
require 'rspec'

describe ArtTypograf do
  it ".process" do
    ArtTypograf.process("- Это \"Типограф\"?\n— Нет, это «Типограф»!").should eq "<p>— Это «Типограф»?<br />\n— Нет, это «Типограф»!<br />\n</p>"
  end

  it "should raise 404 error" do
    lambda {ArtTypograf.process("Тест", :url => 'http://typograf.artlebedev.ru/404')}.should raise_error ArtTypograf::NetworkError
  end

  it "should raise host not found error" do
    lambda {ArtTypograf.process("Тест", :url => 'http://www')}.should raise_error ArtTypograf::NetworkError
  end

  # TODO: mock server for offline testing, for detecting service change
  # TODO: test every option
end

describe ArtTypograf::Client do
  it ".form_xml" do
    pending "TODO"
  end

  it ".check_options" do
    pending "TODO"
  end
end
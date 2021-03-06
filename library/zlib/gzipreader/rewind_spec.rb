require File.expand_path('../../../../spec_helper', __FILE__)
require 'stringio'
require 'zlib'

describe "GzipReader#rewind" do

  before :each do
    @data = '12345abcde'
    @zip = "\037\213\b\000,\334\321G\000\00334261MLJNI\005\000\235\005\000$\n\000\000\000"
    @io = StringIO.new @zip
    ScratchPad.clear
  end

  it "resets the position of the stream pointer" do
    gz = Zlib::GzipReader.new @io
    gz.read
    gz.pos.should == @data.length

    gz.rewind
    gz.pos.should == 0
    gz.lineno.should == 0
  end

  it "resets the position of the stream pointer to data previously read" do
    gz = Zlib::GzipReader.new @io
    first_read = gz.read
    gz.rewind
    first_read.should == gz.read
  end

  it "invokes seek method on the associated IO object" do
    # first, prepare the mock object:
    (obj = mock("io")).should_receive(:get_io).any_number_of_times.and_return(@io)
    def obj.read(args); get_io.read(args); end
    def obj.seek(pos, whence = 0)
      ScratchPad.record :seek
      get_io.seek(pos, whence)
    end

    gz = Zlib::GzipReader.new(obj)
    gz.rewind()

    ScratchPad.recorded.should == :seek
    gz.pos.should == 0
    gz.read.should == "12345abcde"
  end
end

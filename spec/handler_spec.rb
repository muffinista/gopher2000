require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Handler do
  describe "#handle" do
    before(:each) do
      @handler = Gopher::Handler.new("/foo", "ip_address")
      @request = Gopher::Request.new("/foo")
      @handler.should_receive(:request).and_return(@request)
    end

    it 'should call dispatch with request' do
      application.should_receive(:dispatch).with(@request)
      @handler.handle
    end

    it 'pass back result of dispatch' do
      application.should_receive(:dispatch).with(@request).and_return("foo")
      @handler.handle.should == "foo"
    end

    describe "not found" do
      it "should raise not found error" do
        @handler.should_receive(:handle_not_found)
        expect{application.dispatch(@request)}.to raise_error(Gopher::NotFoundError)
        @handler.handle
      end
    end

    describe "error" do
      it "should raise invalid request" do
        @handler.should_receive(:handle_invalid_request)

        @request.selector = "x" * 256
        expect{application.dispatch(@request)}.to raise_error(Gopher::InvalidRequest)

        @handler.handle
      end
    end
  end


  describe "#handle_not_found" do
    before(:each) do
      @handler = Gopher::Handler.new("/foo", "ip_address")
      @request = Gopher::Request.new("/foo")
      @handler.should_receive(:request).and_return(@request)
    end



  end


  describe "#request" do
    before(:each) do
      @handler = Gopher::Handler.new("/foo", "ip_address")
    end

    it "should generate a new request with the proper attrs" do
      @handler.request.selector.should == "/foo"
      @handler.request.ip_address.should == "ip_address"
    end
  end
end

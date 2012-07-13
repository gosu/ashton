
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::Shader do
  before :all do
    $window = Gosu::Window.new 16, 16, false

    @subject = described_class.new # Default code.
    @program = @subject.instance_variable_get :@program
  end

  after :each do
    glUseProgram 0
  end

  describe "initialize" do
    it "should fail if the built-in fragment shader doesn't exist" do
      ->{ described_class.new fragment: :fish }.should raise_error Ashton::ShaderLoadError
    end

    it "should fail if the built-in vertex shader doesn't exist" do
      ->{ described_class.new vertex: :fish }.should raise_error Ashton::ShaderLoadError
    end

    it "should fail if the file-based fragment shader doesn't exist or is bad source" do
      ->{ described_class.new fragment: "/fish.frag" }.should raise_error Ashton::ShaderCompileError
    end

    it "should fail if the file-based fragment shader doesn't exist or is bad source" do
      ->{ described_class.new vertex: "/fish.vert" }.should raise_error Ashton::ShaderCompileError
    end

    it "should set uniform values from the options hash" do
      any_instance_of described_class do |shader|
        mock(shader, :[]=).with :frog, 12
        mock(shader, :[]=).with :fish_paste, 15.0
      end

      described_class.new uniforms: { frog: 12, fish_paste: 15.0 }
    end

    it "should fail if requested to set nonexistent uniform values in the options hash" do
      ->{ described_class.new uniforms: { frog: 12 }} .should raise_error Ashton::ShaderUniformError
    end
  end

  describe "dup" do
    it "should create a new object containing the same source" do
      new_shader = @subject.dup
      new_shader.vertex_source.should eq @subject.vertex_source
      new_shader.fragment_source.should eq @subject.fragment_source
    end
  end

  describe "use" do
    it "should fail if the shader is already active" do
      glUseProgram @program

      ->{ @subject.use {} }.should raise_error Ashton::ShaderError
    end

    it "should fail without a block" do
      ->{ @subject.use }.should raise_error ArgumentError
    end

    it "should pass itself into the block" do
      shader = nil
      @subject.use do |s|
        shader = s
      end

      shader.should eq @subject
    end

    it "should be current within the block?" do
      @subject.use do
        @subject.should be_current
      end
    end

    it "should be not current after the block" do
      @subject.use do
      end

      @subject.should_not be_current
    end
  end

  describe "enable" do
    it "should fail if the shader is already active" do
      glUseProgram @program

      ->{ @subject.enable }.should raise_error Ashton::ShaderError
    end

    it "should toggle current?" do
      ->{ @subject.enable }.should change(@subject, :current?).from(false).to true
    end

  end

  describe "disable" do
    it "should fail if the shader is not active" do
      -> { @subject.disable }.should raise_error Ashton::ShaderError
    end

    it "should toggle current?" do
      @subject.enable
      ->{ @subject.disable }.should change(@subject, :current?).from(true).to false
    end
  end

  describe "current?" do
    it "should be true if the program is current" do
      glUseProgram @program
      @subject.should be_current
    end

    it "should be false if the program isn't current" do
      glUseProgram 0
      @subject.should_not be_current
    end
  end

  describe "image=" do
    pending
  end

  describe "color=" do
    pending
  end

  describe "[]=" do
    pending
  end

  describe "[]" do
    pending "implementation"
  end

  describe "uniform_location" do
    pending
  end

  describe "attribute_location" do
    pending
  end

  describe "compile" do
    pending
  end

  describe "link" do
    pending
  end
end
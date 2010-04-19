# Created with :object in Bond.complete. Is able to complete methods for objects.
# Unlike other missions, this one needs to both match the mission condition and have
# the current object being completed have an ancestor specified by :object.
class Bond::ObjectMission < Bond::Mission
  #:stopdoc:
  attr_reader :object_condition

  def initialize(options={})
    @object_condition = options.delete(:object)
    @object_condition = /^#{Regexp.escape(@object_condition.to_s)}$/ unless @object_condition.is_a?(Regexp)
    options[:on] ||= /(\S+|[^.]+)\.([^.\s]*)$/
    @eval_binding = options[:eval_binding]
    super
  end

  def unique_id
    "#{@object_condition.inspect}+#{@condition.inspect}"
  end

  def _matches?(input)
    super && eval_object(@matched[1]) && @evaled_object.class.respond_to?(:ancestors) &&
      @evaled_object.class.ancestors.any? {|e| e.to_s =~ @object_condition }
  end

  def create_input(input)
    @completion_prefix = @matched[1] + "."
    @action ||= lambda {|e| default_action(e.object) }
    super @matched[2], :object=>@evaled_object
  end

  def default_action(obj)
    obj.methods.map {|e| e.to_s} - OPERATORS
  end
  #:startdoc:
end
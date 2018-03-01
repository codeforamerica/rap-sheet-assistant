class OkayPrint
  def initialize(obj)
    @obj = obj
    @excluded_ivars = []
  end

  def exclude_ivars(*ivars)
    @excluded_ivars = ivars
    self
  end

  def inspect
    "#<#{@obj.class}:0x0000#{@obj.object_id} #{ivar_keys_and_values.join(' ')}>"
  end

  private

  def ivar_keys_and_values
    desired_ivars = @obj.instance_variables.reject { |ivar| @excluded_ivars.include?(ivar) }
    desired_ivars.map { |ivar| "#{ivar}=#{@obj.instance_variable_get(ivar).inspect}" }
  end
end

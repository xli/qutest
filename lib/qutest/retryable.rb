require 'retryable'

class Module
  def retryable *actions
    options = if actions.last.is_a?(Hash)
      actions.pop
    else
      {}
    end
    actions.each do |action|
      module_eval do
        define_method("#{action}_with_retry".to_sym) do |*args, &block|
          retryable(options) do
            send("#{action}_without_retry", *args, &block)
          end
        end
      end
      module_eval do
        alias_method "#{action}_without_retry".to_sym, action.to_sym
        alias_method action.to_sym, "#{action}_with_retry".to_sym
      end
    end
  end
end

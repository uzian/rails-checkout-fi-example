module ApplicationHelper
  def bootstrap_class_for flash_type
    case flash_type
      when :success,"success"
        "alert-success"
      when :error,"error"
        "alert-danger"
      when :alert,"alert"
        "alert-danger"
      when :notice,"notice"
        "alert-info"
      else
        flash_type.to_s
    end
  end  
end

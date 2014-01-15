module BootstrapForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :content_tag, to: :@template

    def initialize(object_name, object, template, options, proc=nil)
      super
      if options.fetch(:help, '').to_sym == :block
        @help_tag = :p
        @help_css = 'help-block'
      else
        @help_tag = :span
        @help_css = 'help-inline'
      end
    end

    %w{email_field search_field text_field text_area password_field collection_select file_field date_select select}.each do |method_name|
      define_method(method_name) do |name, *args|
        options = args.extract_options!.symbolize_keys!
        content_tag :div, class: "control-group#{(' error' if object.errors[name].any?)}"  do
          label(name, options[:label], class: 'control-label') +
          content_tag(:div, class: 'controls') do
            help = object.errors[name].any? ? object.errors[name].join(', ') : options[:help]
            help = content_tag(@help_tag, class: @help_css) { help } if help
            args << options.except(:label, :help)
            if method_name == 'email_field'
            
              content_tag(:div, content_tag(:span, content_tag(:i, nil, class:'icon-envelope'), class:'add-on') + super(name, *args), class: 'input-prepend') + help
            
            elsif method_name == 'search_field'
            
              content_tag(:div, super(name, *args) + content_tag(:button, content_tag(:i, nil, class:'icon-search icon-white', id:'search_append_button'), class: 'btn btn-inverse', type:'button', title:I18n.t(:search_companies_register), class: 'input-append') + help
           
            else
             super(name, *args) + help
            end
          end
        end
      end
    end

    def check_box(name, *args)
      options = args.extract_options!.symbolize_keys!
      content_tag :div, class: "control-group#{(' error' if object.errors[name].any?)}"  do
        content_tag(:div, class: 'controls') do
          args << options.except(:label, :help)
          
          html = super(name, *args) + ' ' + (options[:label].blank? ? object.class.human_attribute_name(name) : options[:label])
          label(name, html, class: 'checkbox')
        end
      end
    end

    def actions(&block)
      content_tag :div, class: "form-actions" do
        block.call
      end
    end

    def primary(name, options = {})
      options.merge! class: 'btn btn-primary'

      submit name, options
    end

    def alert_message(title, *args)
      options = args.extract_options!
      css = options[:class] || "alert alert-error"

      if object.errors.full_messages.any?
        content_tag :div, class: css do
          title
        end
      end
    end
  end
end

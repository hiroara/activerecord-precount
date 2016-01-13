module ActiveRecord
  module Precount
    module ReflectionExtension
      def self.prepended(base)
        class << base
          prepend ClassMethods
        end
      end

      module ClassMethods
        def create(macro, name, scope, options, ar)
          case macro
          when :count_loader
            if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 2
              Reflection::CountLoaderReflection.new(name, scope, options, ar)
            else
              Reflection::AssociationReflection.new(macro, name, scope, options, ar)
            end
          else
            super(macro, name, scope, options, ar)
          end
        end
      end
    end

    module AssociationReflectionExtension
      def klass
        case macro
        when :count_loader
          @klass ||= active_record.send(:compute_type, options[:class_name] || name_without_count.singularize.classify)
        else
          super
        end
      end

      def name_without_count
        name.to_s.sub(/_count$/, "")
      end

      def association_class
        case macro
        when :count_loader
          ActiveRecord::Associations::CountLoader
        else
          super
        end
      end

      def has_many_through_reflection
        return @has_many_through_reflection if defined? @has_many_through_reflection
        ref = self.active_record.reflection_for self.name_without_count
        @has_many_through_reflection = ref.is_a?(ActiveRecord::Reflection::ThroughReflection) ? ref.through_reflection : nil
      end
      def has_many_through_counter?
        !!self.has_many_through_reflection
      end
    end
  end
end

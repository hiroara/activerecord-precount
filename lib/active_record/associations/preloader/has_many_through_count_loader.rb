module ActiveRecord
  module Associations
    class Preloader
      class HasManyThroughCountLoader < CountLoader
        def association_key_name
          has_many_through_reflection.foreign_key
        end

        def association_key_type
          has_many_through_reflection.klass.type_for_attribute(association_key_name.to_s).type
        end

        private

        def has_many_through_reflection
          reflection.has_many_through_reflection
        end

        def query_scope(ids)
          key = has_many_through_reflection.klass.arel_table[association_key_name]
          scope
            .joins(has_many_through_reflection.name)
            .where(key.in(ids))
            .group(key)
            .count(key.name)
        end
      end
    end
  end
end

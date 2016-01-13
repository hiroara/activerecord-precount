module ActiveRecord
  module Precount
    module PreloaderExtension
      def preloader_for(reflection, owners, rhs_klass)
        preloader = super(reflection, owners, rhs_klass)
        return preloader if preloader

        case reflection.macro
        when :count_loader
          reflection.has_many_through_counter? ?
            Associations::Preloader::HasManyThroughCountLoader : Associations::Preloader::CountLoader
        end
      end
    end
  end
end

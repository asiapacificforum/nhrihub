module OutreachMediaMetric
  def rank_text
    "#{rank}: #{text}"
  end

  def to_h
    {:rank => rank, :name => name, :value => rank_text, :id => id}
  end

  def key
    rank.as_word # see lib/ruby_class_extensions.rb
  end

  def name
    I18n.t("activerecord.models.#{class_key}")
  end

  def text
    I18n.t("activerecord.attributes.#{class_key}.rank.#{key}")
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def class_key
    self.class.key
  end

  module ClassMethods
    def key
      name.underscore
    end
  end
end

module TimeLineable
  extend ActiveSupport::Concern

  # Stopped_at is never included in the period because it is the started_at of the next period!
  included do
    validates_presence_of :started_at # , :if => :has_previous?
    validates_presence_of :stopped_at, if: :has_followings?

    scope :at,      ->(at) { where(arel_table[:started_at].lteq(at).and(arel_table[:stopped_at].eq(nil).or(arel_table[:stopped_at].gt(at)))) }
    scope :after,   ->(at) { where(arel_table[:started_at].gt(at)) }
    scope :before,  ->(at) { where(arel_table[:started_at].lt(at)) }
    scope :current, -> { at(Time.zone.now) }

    before_validation do
      following = begin
                    siblings.after(started_at).order(:started_at).first
                  rescue
                    nil
                  end
      if started_at && following
        self.stopped_at = following.started_at
      else
        self.started_at ||= Time.new(1, 1, 1, 0, 0, 0, '+00:00')
        self.stopped_at = nil
      end
    end

    validate do
      if self.started_at && stopped_at
        if stopped_at <= self.started_at
          errors.add(:stopped_at, :posterior, to: self.started_at.l)
        end
      end
    end

    before_update do
      old = old_record
      if old.started_at != self.started_at && previous = old.previous
        previous.update_column(:stopped_at, old.stopped_at)
      end
    end

    after_save do
      if previous = siblings.before(self.started_at).reorder('started_at DESC').first || siblings.find_by(started_at: nil)
        previous.update_column(:stopped_at, self.started_at)
      end
    end

    after_destroy do
      if previous = self.previous
        self.previous.update_column(:stopped_at, stopped_at)
      end
    end
  end

  module ClassMethods
    def first_of_all
      reorder(:started_at).first
    end

    def last_of_all
      reorder(:started_at).last
    end
  end

  def previous
    return nil unless self.started_at
    @previous ||= siblings.find_by(stopped_at: self.started_at)
  end

  def following
    return nil unless stopped_at
    @following ||= siblings.find_by(started_at: stopped_at)
  end

  def has_previous?
    siblings.before(self.started_at).any?
  rescue
    false
  end

  def has_followings?
    siblings.after(self.started_at).any?
  rescue
    false
  end

  def last_for_now?
    siblings.after(self.started_at).before(Time.zone.now).empty?
  end

  private

  def siblings
    fail NotImplementedError, 'Private method :siblings must be implemented'
  end
end

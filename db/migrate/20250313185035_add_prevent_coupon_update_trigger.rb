class AddPreventCouponUpdateTrigger < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE FUNCTION prevent_coupon_update_if_used()
      RETURNS TRIGGER AS $$
      BEGIN
        IF EXISTS (SELECT 1 FROM subscriptions WHERE coupon_id = OLD.id) THEN
          RAISE EXCEPTION 'Cannot update a coupon that is associated with a subscription';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER prevent_coupon_update_trigger
      BEFORE UPDATE ON coupons
      FOR EACH ROW EXECUTE FUNCTION prevent_coupon_update_if_used();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS prevent_coupon_update_trigger ON coupons;
      DROP FUNCTION IF EXISTS prevent_coupon_update_if_used();
    SQL
  end
end

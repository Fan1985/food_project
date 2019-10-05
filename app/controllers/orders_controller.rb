class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_order, only: [:show, :transaction, :destroy, :payment]
  
  def index
    # @orders = Order.where(user: current_cart)
    #或從使用者角度建立
    @orders = current_user.orders.order(created_at: :asc)
  end

  def payment
    @token = braintree_gateway.client_token.generate
  end

  def braintree_gateway
    Braintree::Gateway.new(
      :environment => :sandbox,
      :merchant_id => Figaro.env.BRAINTREE_MERCHANT_ID,
      :public_key => Figaro.env.BRAINTREE_PUBLIC_KEY,
      :private_key => Figaro.env.BRAINTREE_PRIVATE_KEY,
    )
  end
  
  def create
    @order = current_user.orders.new(order_params)
    current_cart.foods.each do |food|
      @order.order_items << OrderItem.new(food_id: food.id, quantity: food.quantity)
    end
    #把購物車裡的東西拿出來，一條一條塞入order_items 
    
    if @order.save
      current_cart.foods.destroy #訂單成立後購物車要清空 
      redirect_to payment_order_path(@order), notice: '訂單已成立' 
    else
      render 'carts/checkout'
    end
  end

  def show
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: '訂單已取消' 
  end

  def transaction
    if @order.may_pay?
      result = braintree_gateway.transaction.sale(
        :amount => "@order.total_price", 
        :payment_method_nonce => params[:payment_method_nonce],
        :options => {
        :submit_for_settlement => true
        }
      )
      if result.success?
        @order.pay!
        redirect_to orders_path, notice: '信用卡結帳完成'
      else
        redirect_to orders_path, notice: '付款失敗'
      end
    else
      redirect_to orders_path, notice: '訂單已完成付款'
    # if @order.may_pay? #may_pay? 是AASM 產生的方法
    #     @order.pay!       #pay! 是AASM 產生的方法 
    # else
    #   redirect_to orders_path, notice: '訂單已完成付款'
    # end  
    end
  end

  private
  def find_order
    @order = current_user.orders.friendly.find(params[:id]) 
  end
  
  def order_params
    params.require(:order).permit(:recipient, :phone, :note)
  end  
end

class CalculationsController < ApplicationController
  def index
  end

  def calc
    @a = params[:a]
    @b = params[:b]
    @operation = params[:operation]
    if @operation.present? and @a.present?
      if @b.blank? and !%w[sin cos tg ctg log !].include? @operation
        render json: {
            status: '1',
            message: 'Необходимо второе число',
        } and return
      end
    end
    render json: make_calc(@a.to_f, @b.to_f, @operation)
  end

  def memorize
    session[:memorized_value] = params[:value] if params[:value].present?
    render json: {
        message: 'Значение успешно сохранено'
    }
  end

  def get_memorized
    if session[:memorized_value].present?
      render json: {
          status: 0,
          value: session[:memorized_value],
      }
    else
      render json: {
          status: 1,
          value: 'Ничего нет в памяти',
      }
    end
  end

  def clear_memory
    session.delete :memorized_value
  end

  protected def make_calc(a, b, operation)
    status = '0'
    message = ''
    case operation
    when '+'
      message = a + b
    when '-'
      message = a - b
    when '*'
      message = a * b

    when '/'
      message = a / b
    when '^'
      message = a ** b
    when '!'
      message = ((1..a).inject(:*) || 1)
    when 'sin'
      message = Math.sin a
    when 'cos'
      message = Math.cos a
    when 'tg'
      message = Math.tan a
    when 'ctg'
      message = (Math.cos(a) / Math.sin(a))
    when 'log'
      message = Math.log10 a
    else
      status = '1'
      message = 'Операция не распознана'
    end

    message = message.to_i if message.to_f == message.to_i

    {
        status: status.to_s,
        message: message.to_s,
    }
  end
end

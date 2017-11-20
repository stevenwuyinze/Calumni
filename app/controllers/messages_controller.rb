class MessagesController < ApplicationController

before_action do
    @conversation = Conversation.find(params[:conversation_id])
end

def index
    @people= People.select{|p| p.email==cookies[:email]}
    @messages = @conversation.messages

    if @messages.length > 10
        @over_ten = true
        @messages = @messages[-10..-1]
    end

    if params[:m]
        @over_ten = false
        @messages = @conversation.messages
    end

    if @messages.last
        if @messages.last.people_id != current_user
            @messages.last.read = true;
        end
    end

    @message = @conversation.messages.new
end


def new
    @people= People.select{|p| p.email==cookies[:email]}
    @message = @conversation.messages.new
end

def create
    @message = @conversation.messages.new(message_params)
    @selected_help = params[:helps] || {}
    @help_responds = params[:responds] || {}
    @people= People.select{|p| p.email==cookies[:email]}

    if @help_responds != {} and @help_responds.keys[0] == "Done"
        @conversation.update_attribute(:help_status, @help_responds.keys[0])

        @people.first.update_attribute(:helped_count, @people.first.helped_count+1)
    elsif @help_responds != {}
        @conversation.update_attribute(:help_status, @help_responds.keys[0])

    elsif message_params[:body].blank?
        flash[:notice] = "Please do not send empty message."

    elsif @selected_help&.keys.size > 1
        flash[:notice] = "Please do not choose more than one help type."



    elsif @selected_help != {}

        @conversation.update_attribute(:help_type, @selected_help.keys[0])
        @conversation.update_attribute(:help_status, "Pending")
        @conversation.update_attribute(:requester, current_user.id)
    elsif !@message.save
        return
    end

    p @conversation
    
    redirect_to conversation_messages_path(@conversation)
end

private

def message_params
    @people= People.select{|p| p.email==cookies[:email]}
    params.require(:message).permit(:body, :people_id)
end


end

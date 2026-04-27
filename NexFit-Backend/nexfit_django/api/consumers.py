# from .models import User, Message
# from . import models
from channels.generic.websocket import AsyncWebsocketConsumer
import json
from channels.db import database_sync_to_async
# from django.contrib.auth import get_user_model
# from .models import Message

# User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.sender_id = self.scope['url_route']['kwargs']['sender_id']
        self.receiver_id = self.scope['url_route']['kwargs']['receiver_id']
        
        self.room_group_name = f'chat_{self.sender_id}_{self.receiver_id}'
        # Join room
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        print('runnning 1')
        await self.accept()

    async def disconnect(self, close_code):
        # Leave room
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )
        print('runnning 2')

    # Receive message from WebSocket
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']
        # Assume sender_id and receiver_id are passed in the message; adjust according to your frontend logic
        sender_id = text_data_json['sender_id']
        receiver_id = text_data_json['receiver_id']
        sender_channel_name = text_data_json.get('sender_channel_name')
        # Save the message to the database
        await self.save_message(sender_id, receiver_id, message)
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'sender_channel_name': sender_channel_name,
            }
            
        )
        
    # Receive message from room group
    async def chat_message(self, event):
        message = event['message']
        sender_channel_name = event.get('sender_channel_name')
        print(message)
        # Send message to WebSocket
        
        if self.channel_name != sender_channel_name:
            await self.send(text_data=json.dumps({
            'message': message
        }))
    # @database_sync_to_async
    # async def save_message(self, sender_id, receiver_id, message):
    #         sender = await self.get_user(sender_id)
    #         receiver = await self.get_user(receiver_id)
    #         await Message.objects.create(sender=sender, receiver=receiver, message=message)
    
    # @database_sync_to_async
    # async def get_user(self, user_id):
    #     return User.objects.get(id=user_id)
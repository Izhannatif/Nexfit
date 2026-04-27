from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path
from api.consumers import ChatConsumer  # Adjust the import based on your project structure

websocket_urlpatterns =[
            path('ws/chat/<int:sender_id>/<int:receiver_id>/', ChatConsumer.as_asgi()),
]

application = ProtocolTypeRouter({
    'websocket': URLRouter(websocket_urlpatterns),
})
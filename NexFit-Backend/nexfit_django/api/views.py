import calendar
from django.http import JsonResponse
from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes,action
from . import serializers
from django.contrib.auth.models import User
from django.db.models import Count
from rest_framework.exceptions import AuthenticationFailed
import jwt
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework import generics, permissions, status
from rest_framework_simplejwt.views import TokenObtainPairView
import datetime
from rest_framework.permissions import IsAuthenticated, AllowAny
from . import models
from django.utils import timezone


class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = TokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        try:
            response = super().post(request, *args, **kwargs)
            return response
        except AuthenticationFailed as e:
            return Response({'detail': str(e)}, status=status.HTTP_401_UNAUTHORIZED)
        
        except Exception as e:
            return Response({'detail': 'Something went wrong. Please try again later.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class RegisterUserView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = serializers.RegisterUserSerializer

    def post(self, request):
        serializer = serializers.RegisterUserSerializer(
            data=request.data,
            context={
                "gym_id": request.data.get("gym_id"),
                "contact": request.data.get("contact"),
                "trainer": request.data.get("trainer"),
            },
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)


@api_view(['PUT'])
def update_user_view(request,id):
    print(id)
    try:
        user = GymUser.objects.get(id = id)
    except GymUser.DoesNotExist:
        return Response(
            {"error": "Updating Gym User not found."}, status=status.HTTP_404_NOT_FOUND,)
    serializer = GymUserSerializer(user, data = request.data,partial=True,)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    print(serializer._errors)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    


class RegisterTrainerView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = serializers.RegisterTrainerSerializer

    def post(self, request):
        serializer = serializers.RegisterTrainerSerializer(
            data=request.data,
            context={
                "gym_id": request.data.get("gym_id"),
                "contact": request.data.get("contact"),
                "certification": request.data.get("certification"),
                "monthly_charges": request.data.get("monthly_charges"),
            },
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)


class LoginView(APIView):
    def post(self, request):
        username = request.data["username"]
        password = request.data["password"]

        user = User.objects.filter(username=username).first()

        gym_user = models.GymUser.objects.get(user=user)

        if user is None:
           
            return Response('Invalid User.', status=400);
        if not user.check_password(password):
            return Response('Icorrect username of password.', status=400);

        payload = {
            "id": user.id,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=60),
            "iat": datetime.datetime.utcnow(),
        }

        token = jwt.encode(payload, "secret", algorithm="HS256")
        # .decode("utf-8")
        response = Response()
        response.set_cookie(key="jwt", value=token, httponly=True)

        return Response(
            {
                "jwt": token,
                "user_id": user.id,
                "email": user.email,
                "username": user.username,
                "gym_user_id": gym_user.id,
                "contact": gym_user.contact,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "is_admin": gym_user.isAdmin,
                "is_user": gym_user.isUser,
                "is_trainer": gym_user.isTrainer,
                "trainer_selected": gym_user.trainerSelected,
                "trainer_id": gym_user.trainer.id,
                "trainer_user_id": gym_user.trainer.user.id,
                "number_of_tokens": gym_user.number_of_tokens,
                "membership": gym_user.membership,
                # "trainer":user_trainer.id,
                # "trainer_id":gym_user.trainer.id,
            }
        )


class TrainerLoginView(APIView):
    def post(self, request):
        username = request.data["username"]
        password = request.data["password"]

        user = User.objects.filter(username=username).first()

        gym_trainer = models.GymTrainer.objects.get(user=user)

        # trainer = models.GymTrainer.objects.get(user=gym_user.trainer.user);

        print(gym_trainer)

        if user is None:
            raise AuthenticationFailed("User not found")
        if not user.check_password(password):
            raise AuthenticationFailed("Incorrect Password")

        payload = {
            "id": user.id,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=60),
            "iat": datetime.datetime.utcnow(),
        }

        token = jwt.encode(payload, "secret", algorithm="HS256")
        # .decode("utf-8")
        response = Response()
        response.set_cookie(key="jwt", value=token, httponly=True)

        return Response(
            {
                "jwt": token,
                "user_id": user.id,
                "email": user.email,
                "username": user.username,
                "contact": gym_trainer.contact,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "is_admin": gym_trainer.isAdmin,
                "is_user": gym_trainer.isUser,
                "is_trainer": gym_trainer.isTrainer,
                "trainer_id": gym_trainer.id,
            }
        )

        return Response(user)


class UserView(APIView):
    def get(self, request):
        token = request.COOKIES.get("jwt")
        if not token:
            raise AuthenticationFailed("Unauthenticated")

        try:
            payload = jwt.decode(token, "secret", algorithm=["HS256"])
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed("unauthenticated")

        user = User.objects.get(payload["id"])
        serializer = serializers.UserSerializer(user)

        return Response(serializer.data)

        # return Response(token)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getUserData(request, id):
    user = User.objects.get(id=id)
    serializer = serializers.UserSerializer(user, many=False)
    data = serializer.data
    return Response(data)

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getGymUserData(request, id):
    # user = User.objects.get(id=id)
    gym_user = models.GymUser.objects.get(id=id)
    serializer = serializers.GymUserSerializer(gym_user, many=False)
    data = serializer.data
    return Response(data)



@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getUserAllData(request, id):
    user = User.objects.get(id=id)
    user = models.GymUser.objects.get(user=user)
    serializer = serializers.GymUserSerializer(user, many=False)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getTrainerAllData(request, id):
    user = User.objects.get(id=id)
    user = models.GymTrainer.objects.get(user=user)
    serializer = serializers.GymTrainerSerializer(user, many=False)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getGymAdminData(request, id):
    gymadmin = models.GymAdmin.objects.get(user=User.objects.get(id=id))
    # user = User.objects.get(id=id)
    serializer = serializers.GymAdminSerializer(gymadmin, many=False)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllGymAdmins(request):
    gymadmin = models.GymAdmin.objects.all()
    # user = User.objects.get(id=id)
    serializer = serializers.GymAdminSerializer(gymadmin, many=True)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllGymUsers(request, id):
    gymusers = models.GymUser.objects.filter(gym=id)
    serializer = serializers.GymUserSerializer(gymusers, many=True)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllGymTrainers(request, id):
    gymTrainers = models.GymTrainer.objects.filter(gym=id)
    serializer = serializers.GymTrainerSerializer(gymTrainers, many=True)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllGymEquipments(request, id):
    total_quantity = 0
    gymEquipments = models.GymEquipments.objects.filter(gym=id)
    serializer = serializers.GymEquipmentSerializer(gymEquipments, many=True)
    data = serializer.data
    for d in data:
        print(d['quantity']);
        total_quantity += d['quantity']
    print(total_quantity);
    response_data = {
        'total_quantity': total_quantity,
        'equipment_list': data,
    }
    return Response(response_data)
    


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllGymExercises(
    request,
):
    gymEquipments = models.Exercise.objects.filter()
    serializer = serializers.GymExerciseSerializer(gymEquipments, many=True)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllExercises(request):
    gymExercises = models.Exercise.objects.all().order_by("-image")
    serializer = serializers.GymExerciseSerializer(gymExercises, many=True)
    data = serializer.data
    return Response(data)


class AddEquipmentView(generics.CreateAPIView):
    queryset = models.GymEquipments.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = serializers.AddEquipmentSerializer

    def post(self, request):
        serializer = serializers.AddEquipmentSerializer(
            data=request.data,
            context={
                "gym_id": request.data.get("gym_id"),
            },
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)


class AddExerciseView(generics.CreateAPIView):
    queryset = models.Exercise.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = serializers.AddExerciseSerializer

    def post(self, request):
        serializer = serializers.AddExerciseSerializer(
            data=request.data,
        )

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)


class AddTokenPlanView(generics.CreateAPIView):
    queryset = models.GymTokenPlans.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = serializers.AddGymTokenPlanSerializer

    def post(self, request):
        serializer = serializers.AddGymTokenPlanSerializer(
            data=request.data,
            context={
                "gym_id": request.data.get("gym_id"),
            },
        )

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getGymUser(request, username, id):
    try:
        gym = models.Gym.objects.get(pk=id)
    except models.Gym.DoesNotExist:
        raise serializers.ValidationError("Invalid Gym ID")

    gym_user = models.GymUser.objects.filter(
        user__username__icontains=username, gym=gym
    )
    serializer = serializers.GymUserSerializer(gym_user, many=True)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def getAllGymTokenPlans(request, id):
    token_plans = models.GymTokenPlans.objects.filter(gym=id)
    serializer = serializers.GymTokenPlanSerializer(token_plans, many=True)
    data = serializer.data
    return Response(data)


class GymTokenPurchaseView(generics.CreateAPIView):
    queryset = models.GymPurchases.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = serializers.AddGymPurchaseSerializer

    def post(self, request):

        serializer = serializers.AddGymPurchaseSerializer(
            data=request.data,
            context={
                "gym_id": request.data.get("gym_id"),
                "plan_id": request.data.get("plan_id"),
                "gym_user_id": request.data.get("gym_user_id"),
                "number_of_tokens": request.data.get("number_of_tokens"),
                "plan_price": request.data.get("plan_price"),
                "token_plan_id": request.data.get("token_plan_id"),
                "name": request.data.get("name"),
                "start_date": request.data.get("start_date"),
                "end_date": request.data.get("end_date"),
            },
        )
        try:
            gym = models.Gym.objects.get(pk=request.data.get("gym_id"))
            print(gym)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Gym ID")
        try:
            plan = models.GymTokenPlans.objects.get(
                pk=request.data.get("token_plan_id")
            )
            print(plan)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Plan ID")
        try:
            gym_user = models.GymUser.objects.get(pk=request.data.get("gym_user_id"))
            print(gym_user)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Gym User ID")

        gym_user.add_tokens(request.data.get("number_of_tokens"))

        # start_date = datetime.now().date()
        # end_date = start_date + timedelta(days=30)

        token_plan = models.GymPurchases.objects.create(
            gym=gym,
            gym_user=gym_user,
            token_plan=plan,
            number_of_tokens=request.data.get("number_of_tokens"),
            price=request.data.get("plan_price"),
            start_date=request.data.get("start_date"),
            end_date=request.data.get("end_date"),
        )
        token_plan.save()
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)


@api_view(["POST"])
def scan_qr_code_and_mark_attendance(request):
    qr_code_data = request.data.get("qr_code_data")
    user_id = request.data.get("user_id")
    print(qr_code_data)
    print(user_id)
    try:
        user = models.GymUser.objects.get(user=user_id)
        print(user)
        
        if qr_code_data == "valid_qr_code":
            print("running")
            today = timezone.now().date()
            if models.Attendance.objects.filter(user=user.user, date=today).exists():
                print("Attendance already marked for today.")
                return Response("Attendance already marked for today", status=201)

            if user.number_of_tokens > 0:
                models.Attendance.objects.create(user=user.user, date=today)
                user.number_of_tokens -= 1
                user.save()
                return Response({"message": "Attendance marked successfully"})
            else:
                print("Insufficient Tokens")
                return Response({"error": "Insufficient tokens"}, status=400)
        else:
            return Response({"error": "Invalid QR code"}, status=400)
    except models.GymUser.DoesNotExist:
        return Response({"error": "User not found"}, status=404)
    except models.Attendance.DoesNotExist:
        print("No attendance record found for the user.")
        return Response(
            {"error": "No attendance record found for the user."}, status=400
        )
    except Exception as e:
        return Response({"error": str(e)}, status=500)



@api_view(["POST"])
def scan_qr_code_and_mark_trainer_attendance(request):
    qr_code_data = request.data.get("qr_code_data")
    user_id = request.data.get("user_id")
    print(qr_code_data)
    print(user_id)
    try:
        user = models.GymTrainer.objects.get(user=user_id)
        print(user)
        
        if qr_code_data == "valid_qr_code":
            print("running")
            today = timezone.now().date()
            if models.Attendance.objects.filter(user=user.user, date=today).exists():
                print("Attendance already marked for today.")
                return Response("Attendance already marked for today", status=201)
            else:
                models.Attendance.objects.create(user=user.user, date=today)
                user.save()
                return Response({"message": "Attendance marked successfully"})
        else:
            return Response({"error": "Invalid QR code"}, status=400)
    except models.GymTrainer.DoesNotExist:
        return Response({"error": "Trainer not found"}, status=404)
    except models.Attendance.DoesNotExist:
        print("No attendance record found for the user.")
        return Response(
            {"error": "No attendance record found for the Trainer."}, status=400
        )
    except Exception as e:
        return Response({"error": str(e)}, status=500)    

from rest_framework import viewsets
from .models import Attendance, DietPlan, GymPurchases, GymUser, Message, WorkoutPlan, WorkoutPlanDay
from .serializers import (
    DietPlanSerializer,
    GymUserSerializer,
    MessageSerializer,
    # UpdateUserSerializer,
    UserSerializer,
    WorkoutPlanDaySerializer,
    WorkoutPlanSerializer,
)


class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    print(queryset)
    serializer_class = MessageSerializer


from pusher import Pusher
from django.db.models import Q  # Import the Q object

# configure Pusher
pusher = Pusher(
    app_id="1798339",
    key="a199a1c31350a0a266a7",
    secret="12c53b421b41499ea943",
    cluster="ap2",
    ssl=True,
)


class MessageView(APIView):
    def post(self, request, *args, **kwargs):
        sender_id = request.data.get("sender-id")
        receiver_id = request.data.get("receiver-id")
        message = request.data.get("message")

        sender = models.User.objects.get(id=sender_id)
        receiver = models.User.objects.get(id=receiver_id)

        print(sender)
        print(receiver)
        print(message)
        # Save message to database
        msg = Message(sender=sender, receiver=receiver, message=message)
        msg.save()

        # Send message using Pusher
        pusher.trigger(
            "chat_channel",
            "new_message",
            {
                "senderId": sender.id,
                "sender": sender.username,
                "receiver": receiver.username,
                "message": message,
                "timestamp": msg.timestamp.strftime("%Y-%m-%d %H:%M:%S"),
            },
        )

        return Response(message)


def get_chat_history(request, sender_id, receiver_id):
    print(sender_id)
    print(receiver_id)
    sender = models.User.objects.get(id=sender_id)
    receiver = models.User.objects.get(id=receiver_id)

    # Fetch messages from the database
    messages = (
        Message.objects.filter(
            (Q(sender=sender) & Q(receiver=receiver))
            | (Q(sender=receiver) & Q(receiver=sender))
        )
        .order_by("timestamp")
        .values("sender_id", "receiver_id", "message", "timestamp")
    )
    print(messages)
    return JsonResponse(list(messages), safe=False)


@api_view(["GET"])
def getUserAttendance(request, id):
    user = models.User.objects.get(id=id)
    attendance = models.Attendance.objects.filter(user=user)
    serializer = serializers.AttendanceSerializer(attendance, many=True)
    data = serializer.data
    return Response(data)


@api_view(["GET"])
def getTraineesList(request, id):
    trainer = models.GymTrainer.objects.get(user=id)
    trainees = models.GymUser.objects.filter(trainer=trainer)
    serializer = serializers.GymUserSerializer(trainees, many=True)
    data = serializer.data
    return Response(data)


class DietPlanViewSet(viewsets.ModelViewSet):
    queryset = DietPlan.objects.all()
    serializer_class = DietPlanSerializer
    # permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return DietPlan.objects.all()
        elif hasattr(user, "gymtrainer"):
            return DietPlan.objects.filter(trainer=user.gymtrainer)
        elif hasattr(user, "gymuser"):
            return DietPlan.objects.filter(trainees=user.gymuser)
        return DietPlan.objects.none()

    def perform_create(self, serializer):
        serializer.save(trainer=self.request.user.gymtrainer)


class TraineeDietPlansView(APIView):
    # permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        print(user)
        try:
            trainee = models.GymUser.objects.get(user=user, isUser=True)
        except models.GymUser.DoesNotExist:
            return Response(
                {"detail": "User is not a trainee."}, status=status.HTTP_400_BAD_REQUEST
            )

        diet_plans = DietPlan.objects.filter(trainee=trainee)
        serializer = DietPlanSerializer(diet_plans, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["GET"])
def getTraineeDietPlans(request, id):
    user = models.User.objects.get(id=id)
    try:
        trainee = models.GymUser.objects.get(user=user, isUser=True)
    except models.GymUser.DoesNotExist:
        return Response(
            {"detail": "User is not a trainee."}, status=status.HTTP_400_BAD_REQUEST
        )

    diet_plans = DietPlan.objects.filter(trainees=trainee)
    serializer = DietPlanSerializer(diet_plans, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["GET"])
def getTrainerDietPlans(request, id):
    trainer = models.GymTrainer.objects.get(id=id)
    diet_plans = models.DietPlan.objects.filter(trainer=trainer)
    serializer = DietPlanSerializer(diet_plans, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["POST"])
# @permission_classes([IsAuthenticated])
def create_diet_plan(request, id):
    trainer = models.GymTrainer.objects.get(id=id)
    print(trainer)
    print(request.data)
    if trainer is None:
        print("running1")
        return Response(
            {"detail": "Only trainers can create diet plans."},
            status=status.HTTP_403_FORBIDDEN,
        )
    print(request.content_type)
    print("running2")
    serializer = DietPlanSerializer(data=request.data)
    print("running4")
    print(request.data)
    if serializer.is_valid():
        print("running5")
        serializer.save(
            trainer=trainer,
        )
        print("running 7")
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    print("running6")
    print(serializer.error_messages)
    print(serializer._errors)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "PUT"])
def diet_plan_detail(request, id):
    try:
        diet_plan = DietPlan.objects.get(id=id)
    except DietPlan.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == "GET":
        serializer = DietPlanSerializer(diet_plan)
        return Response(serializer.data)
    elif request.method == "PUT":
        serializer = DietPlanSerializer(diet_plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "PUT"])
# @permission_classes([IsAuthenticated])
def edit_diet_plan(request, id):
    try:
        diet_plan = DietPlan.objects.get(id=id)
    except DietPlan.DoesNotExist:
        return Response(
            {"detail": "Diet plan not found."}, status=status.HTTP_404_NOT_FOUND
        )

    if request.method == "GET":
        serializer = DietPlanSerializer(diet_plan)
        print(serializer._errors)
        return Response(serializer.data)

    if request.method == "PUT":
        days_data = request.data["days"]
        trainees = request.data["trainees"]
        serializer = DietPlanSerializer(
            diet_plan,
            data=request.data,
            context={"plan_id": id, "days_data": days_data, "trainees": trainees},
        )
        if serializer.is_valid():
            serializer.save()
            print(serializer._errors)
            return Response(serializer.data, status=status.HTTP_200_OK)
        print(serializer._errors)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["DELETE"])
def delete_diet_plan_day(request, id):
    try:
        diet_plan_day = models.DietPlanDay.objects.get(id=id)
        print(diet_plan_day)
        diet_plan_day.delete()
        return Response(
            {"message": "Diet plan day deleted successfully"}, status=status.HTTP_200_OK
        )
    except models.DietPlanDay.DoesNotExist:
        return Response(
            {"message": "Diet plan day not found"}, status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response(
            {"message": "Error occurred", "error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET"])
def getUserPurchases(request, id):
    try:
        gym_user = models.GymUser.objects.get(id=id)
        print(gym_user)
        gym_purchases = models.GymPurchases.objects.filter(gym_user=gym_user)
        print(gym_purchases)
        serializer = serializers.AddGymPurchaseSerializer(gym_purchases, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except models.GymPurchases.DoesNotExist:
        return Response(
            {"message": "Purchase not found"}, status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        return Response(
            {"message": "Error occurred", "error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


class WorkoutPlanViewSet(viewsets.ModelViewSet):
    queryset = WorkoutPlan.objects.all()
    serializer_class = WorkoutPlanSerializer
    # permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return WorkoutPlan.objects.all()
        elif hasattr(user, "gymtrainer"):
            return WorkoutPlan.objects.filter(trainer=user.gymtrainer)
        elif hasattr(user, "gymuser"):
            return WorkoutPlan.objects.filter(trainees=user.gymuser)
        return WorkoutPlan.objects.none()

    def perform_create(self, serializer):
        serializer.save(trainer=self.request.user.gymtrainer)
        
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def update(self, request, *args, **kwargs):
        print(request.data)
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        print(serializer._errors)
        return Response(serializer.data)

    @action(detail=True, methods=['delete'], url_path='delete-day/(?P<day_id>[^/.]+)')
    def delete_day(self, request, pk=None, day_id=None):
        try:
            day = WorkoutPlanDay.objects.get(id=day_id, workout_plan_id=pk)
            day.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except WorkoutPlanDay.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)


class WorkoutPlanDayViewSet(viewsets.ModelViewSet):
    queryset = WorkoutPlanDay.objects.all()
    serializer_class = WorkoutPlanDaySerializer
    # permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save()


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def get_workout_plan_detail(request, pk):
    try:
        workout_plan = WorkoutPlan.objects.get(pk=pk)
    except WorkoutPlan.DoesNotExist:
        return Response(
            {"error": "WorkoutPlan not found."}, status=status.HTTP_404_NOT_FOUND
        )

    if request.method == "GET":
        serializer = WorkoutPlanSerializer(workout_plan)
        return Response(serializer.data)


@api_view(["PUT"])
# @permission_classes([IsAuthenticated])
def update_workout_plan(request, pk):
    print(request.data)
    workout_plan_data = request.data['Workout_plan_days']
    trainees = request.data['trainees']
    trainer_id = request.data['trainer_id']
    try:
        workout_plan = WorkoutPlan.objects.get(pk=pk)
    except WorkoutPlan.DoesNotExist:
        return Response(
            {"error": "WorkoutPlan not found."}, status=status.HTTP_404_NOT_FOUND
        )

    serializer = WorkoutPlanSerializer(workout_plan, data=request.data, partial=True, context={'workout_plan_data':workout_plan_data, 'trainer_id':trainer_id, 'trainees':trainees})
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    print(serializer._errors)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["DELETE"])
# @permission_classes([IsAuthenticated])
def delete_workout_plan(request, pk):
    try:
        workout_plan = WorkoutPlan.objects.get(pk=pk)
        workout_plan.delete()
        return Response(
            {"message": "WorkoutPlan deleted successfully."}, status=status.HTTP_200_OK
        )
    except WorkoutPlan.DoesNotExist:
        return Response(
            {"error": "WorkoutPlan not found."}, status=status.HTTP_404_NOT_FOUND
        )


@api_view(["POST"])
# @permission_classes([IsAuthenticated])
def create_workout_plan(request):
    workout_day_data = request.data["days"]
    serializer = WorkoutPlanSerializer(
        data=request.data, context={"workout_day_data": workout_day_data}
    )
    trainer_id = request.data["trainer"]
    trainees = request.data["trainees"]
    trainer = models.GymTrainer.objects.get(id=trainer_id)
    if serializer.is_valid():
        serializer.save(trainer=trainer, trainees=trainees)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    print(serializer._errors)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def list_workout_plans(request, id):
    user = models.GymTrainer.objects.get(id=id)
    print(id)
    if user is not None:
        workout_plans = WorkoutPlan.objects.filter(trainer=user)
    else:
        workout_plans = WorkoutPlan.objects.none()
    serializer = WorkoutPlanSerializer(workout_plans, many=True)
    return Response(serializer.data)

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def list_trainee_workout_plans(request, id):
    user = models.GymUser.objects.get(id=id)
    print(id)
    if user is not None:
        workout_plans = WorkoutPlan.objects.filter(trainees=user)
    else:
        workout_plans = WorkoutPlan.objects.none()
    serializer = WorkoutPlanSerializer(workout_plans, many=True)
    return Response(serializer.data)

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def list_workout_plan_days(request, id):
    try:
        workout_plan = WorkoutPlan.objects.get(id=id)
    except WorkoutPlan.DoesNotExist:
        return Response(
            {"error": "WorkoutPlan not found."}, status=status.HTTP_404_NOT_FOUND
        )

    workout_plan_days = workout_plan.Workout_plan_days.all()
    serializer = WorkoutPlanDaySerializer(workout_plan_days, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def getWorkoutPlan(request, id):
    try:
        workout_plan  = WorkoutPlan.objects.get(id=id)
    except WorkoutPlan.DoesNotExist:
        return Response(
            {"error": "WorkoutPlan not found."}, status=status.HTTP_404_NOT_FOUND
        )
    serializer = serializers.WorkoutPlanSerializer(workout_plan,many=False)
    return Response(serializer.data)
@api_view(["GET"])
def get_weekly_attendance(request):
    # Get the start of the week (Monday)
    week_str = request.GET.get("week", "")
    try:
        start_date = datetime.datetime.strptime(week_str, '%Y-%m-%d')
       
    except ValueError:
        start_date = timezone.now().date()

    start_of_week = start_date - datetime.timedelta(days=start_date.weekday())
    end_of_week = start_of_week + datetime.timedelta(days=6)

    # Initialize a dictionary with 0 for each day of the week
    attendance_data = {calendar.day_name[i]: 0 for i in range(7)}

    # Query attendance records for the specified week
    attendances = Attendance.objects.filter(date__range=[start_of_week, end_of_week])

    for attendance in attendances:
        day_name = calendar.day_name[attendance.date.weekday()]
        attendance_data[day_name] += 1

    return Response(attendance_data)

from django.db.models import Sum
from django.db.models.functions import TruncMonth

@api_view(['GET'])
def monthly_revenue(request):
    # Get the current month and year
    current_date = datetime.datetime.now().date()
    current_month = current_date.month
    current_year = current_date.year

    # Calculate the start date for the six months ago
    six_months_ago = current_date - datetime.timedelta(days=180)

    # Query revenue data for the last six months
    revenue_data = GymPurchases.objects \
        .filter(start_date__gte=six_months_ago) \
        .annotate(month=TruncMonth('start_date')) \
        .values('month') \
        .annotate(total_revenue=Sum('price')) \
        .order_by('month')

    # Create a dictionary with revenue data for the last six months
    result = {}
    for data in revenue_data:
        month_name = data['month'].strftime('%B')
        result[month_name] = data['total_revenue']

    # Fill in any missing months with default revenue 0
    for i in range(6):
        month = current_month - i
        if month <= 0:
            month += 12
            current_year -= 1
        month_name = calendar.month_name[month]
        if month_name not in result:
            result[month_name] = 0

    # Sort the result by month
    result = {k: result[k] for k in sorted(result, key=lambda x: list(calendar.month_name).index(x))}

    return Response(result)

class AddPersonalGoalView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = serializers.PersonalGoalSerializer(data=request.data)
        if serializer.is_valid():
            print(serializer._validated_data)
            user_id = serializer.validated_data['gym_user']
            print(user_id)
            user = GymUser.objects.get(id=user_id)
            print(user)
            goal = models.PersonalGoal(
                gym_user=user,
                goal_type=serializer.validated_data['goal_type'],
                target_value=serializer.validated_data['target_value'],
                start_date=serializer.validated_data['start_date'],
                end_date=serializer.validated_data['end_date'],
            )
            goal.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        print(serializer._errors);
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PersonalGoalListCreateView(generics.ListCreateAPIView):
    queryset = models.PersonalGoal.objects.all()
    serializer_class = serializers.PersonalGoalSerializer
    # permission_classes = [permissions.IsAuthenticated]
    print('running');
    def get_queryset(self):
        return self.queryset.filter(gym_user__user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(gym_user=self.request.user.gymuser)

# class PersonalGoalDetailView(generics.RetrieveUpdateDestroyAPIView):
#     queryset = models.PersonalGoal.objects.all()
#     serializer_class = serializers.PersonalGoalSerializer
#     # permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         return self.queryset.filter(gym_user__user=self.request.user)

# class WeeklyProgressListCreateView(generics.ListCreateAPIView):
#     queryset = models.WeeklyProgress.objects.all()
#     serializer_class = serializers.WeeklyProgressSerializer
#     # permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         return self.queryset.filter(personal_goal__gym_user__user=self.request.user)

#     def perform_create(self, serializer):
#         personal_goal = serializer.validated_data['personal_goal']
#         if personal_goal.gym_user.user != self.request.user:
#             return Response({'detail': 'You do not have permission to add progress for this goal.'}, status=status.HTTP_403_FORBIDDEN)
#         serializer.save()

# class WeeklyProgressDetailView(generics.RetrieveUpdateDestroyAPIView):
#     queryset = models.WeeklyProgress.objects.all()
#     serializer_class = serializers.WeeklyProgressSerializer
#     # permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         return self.queryset.filter(personal_goal__gym_user__user=self.request.user)

class PersonalGoalDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = models.PersonalGoal.objects.all()
    serializer_class = serializers.PersonalGoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user_id = self.request.data.get('user_id')  # Extract user ID from frontend
        if user_id:
            return self.queryset.filter(gym_user__user_id=user_id)
        return self.queryset.none()  # Return an empty queryset if user ID is not provided
class WeeklyProgressListCreateView(generics.ListCreateAPIView):
    queryset = models.WeeklyProgress.objects.all()
    serializer_class = serializers.WeeklyProgressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        user_id = self.request.query_params.get('user_id') or (user.id if user.is_authenticated else None)
        if user_id:
            return self.queryset.filter(personal_goal__gym_user__user_id=user_id)
        return self.queryset.none()

    def perform_create(self, serializer):
        user = self.request.user
        user_id = self.request.data.get('user_id') or (user.id if user.is_authenticated else None)
        if user_id:
            personal_goal = serializer.validated_data.get('personal_goal')
            if personal_goal and personal_goal.gym_user.user_id == int(user_id):
                serializer.save()
            else:
                raise PermissionDenied('You do not have permission to add progress for this goal.')
        else:
            raise ValidationError('User ID is required.')

class WeeklyProgressDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = models.WeeklyProgress.objects.all()
    serializer_class = serializers.WeeklyProgressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        user_id = self.request.query_params.get('user_id') or (user.id if user.is_authenticated else None)
        if user_id:
            return self.queryset.filter(personal_goal__gym_user__user_id=user_id)
        return self.queryset.none()
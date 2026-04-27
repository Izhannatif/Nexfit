from django.urls import path, include
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from nexfit_django import settings
from . import views
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    AddPersonalGoalView,
    MessageView,
    MessageViewSet,
    PersonalGoalDetailView,
    PersonalGoalListCreateView,
    RegisterUserView,
    # UpdateUserView,
    LoginView,
    TokenObtainPairView,
    RegisterTrainerView,
    AddEquipmentView,
    AddExerciseView,
    AddTokenPlanView,
    GymTokenPurchaseView,
    TrainerLoginView,
    DietPlanViewSet,
    WeeklyProgressDetailView,
    WeeklyProgressListCreateView,

)

router = DefaultRouter()
router.register(r"messages", MessageViewSet)
router.register(r"diet-plans", DietPlanViewSet)  # Register DietPlanViewSet
router.register(r'workout-plans', views.WorkoutPlanViewSet)
router.register(r'workout-plan-days', views.WorkoutPlanDayViewSet)

# router.register(r'conversations', ConversationViewSet)

urlpatterns = [
    path("register-user/", RegisterUserView.as_view()),
    path("register-trainer/", RegisterTrainerView.as_view()),
    path("login/", LoginView.as_view()),
    path("trainer-login/", TrainerLoginView.as_view()),
    path("token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("user/<str:id>/", views.getUserData),
    path('update-user/<str:id>/', views.update_user_view),
    path("admin/<str:id>/", views.getGymAdminData),
    path("all-admin/", views.getAllGymAdmins),
    path("gym-users/<str:id>/", views.getAllGymUsers),
    path('get-user/<str:id>/', views.getGymUserData),
    path("gym-trainers/<str:id>/", views.getAllGymTrainers),
    path("add-equipment/", AddEquipmentView.as_view()),
    path("add-exercise/", AddExerciseView.as_view()),
    path("add-token-plan/", AddTokenPlanView.as_view()),
    path("get-user/<str:id>/<str:username>/", views.getGymUser),
    path("<str:id>/get-token-plans/", views.getAllGymTokenPlans),
    path("add-plan-purchase/", GymTokenPurchaseView.as_view()),
    path("<str:id>/all-equipments/", views.getAllGymEquipments),
    path("/all-exercises/", views.getAllGymExercises),
    path("exercises/", views.getAllExercises),
    path("userdata/<str:id>/", views.getUserAllData),
    path("trainerdata/<str:id>/", views.getTrainerAllData),
    path("scan-qr-code/", views.scan_qr_code_and_mark_attendance),
    path("scan-qr-code-trainer/", views.scan_qr_code_and_mark_trainer_attendance),
    path("send_message/", MessageView.as_view(), name="send_message"),
    path("get-trainees/<str:id>/", views.getTraineesList),
    path("get-user-attendance/<str:id>/", views.getUserAttendance),
    path("<str:id>/trainee-diet-plans/", views.getTraineeDietPlans),
    path("<str:id>/trainer-diet-plans/", views.getTrainerDietPlans),
    path("<str:id>/create-diet-plan/", views.create_diet_plan, name="create_diet_plan"),
    path("diet-plan/<str:id>/", views.diet_plan_detail, name="diet_plan_details"),
    path("edit-diet-plan/<str:id>/", views.edit_diet_plan, name="update_diet_plan"),
    path("delete-diet-plan-day/<str:id>/", views.delete_diet_plan_day),
    path("<str:id>/get-user-purchases/", views.getUserPurchases),
    path('workout-plans/<int:pk>/', views.get_workout_plan_detail, name='workout-plan-detail'),
    path('workout-plans/<int:pk>/update/', views.update_workout_plan, name='update-workout-plan'),
    path('workout-plans/<int:pk>/delete/', views.delete_workout_plan, name='delete-workout-plan'),
    path('workout-plans/create/', views.create_workout_plan, name='create-workout-plan'),
    path('<str:id>/workout-plans/list/', views.list_workout_plans, name='list-workout-plans'),
    path('<str:id>/trainee-workout-plans/list/', views.list_trainee_workout_plans, name='list-workout-plans'),
    path('attendance/weekly/', views.get_weekly_attendance, name='get_weekly_attendance'),
    path('workout-plan/<int:id>/days/', views.list_workout_plan_days, name='list-workout-plan-days'),
    path('workout-plan/<str:id>', views.getWorkoutPlan),
    path('revenue/monthly/', views.monthly_revenue, name='monthly_revenue'),
    # path('personal-goals/', PersonalGoalListCreateView.as_view(), name='personal-goal-list-create'),
    path('personal-goals/', AddPersonalGoalView.as_view(), name='add_personal_goal'),
    path('personal-goals/<int:pk>/', PersonalGoalDetailView.as_view(), name='personal-goal-detail'),
    path('weekly-progress/', WeeklyProgressListCreateView.as_view(), name='weekly-progress-list-create'),
    path('weekly-progress/<int:pk>/', WeeklyProgressDetailView.as_view(), name='weekly-progress-detail'),
    path(
        "chat-history/<int:sender_id>/<int:receiver_id>/",
        views.get_chat_history,
        name="chat_history",
    ),
    path("", include(router.urls)),
    # path('chats/<str:username>/', views.ChatListCreateAPIView.as_view(), name='chats'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

from djoser.serializers import UserCreateSerializer
from rest_framework import serializers
from django.contrib.auth.models import User
from rest_framework.validators import UniqueValidator
from . import models
from datetime import datetime, timedelta
from rest_framework import serializers
from .models import DietPlan, DietPlanDay, GymTrainer, GymUser, Message, PersonalGoal


class MyUserCreateSerializer(UserCreateSerializer):
    class Meta(UserCreateSerializer.Meta):
        model = User
        fields = ["id", "username", "email", "first_name", "last_name"]

    def create(self, validated_data):
        password = validated_data.pop("password", None)
        instance = self.Meta.model(**validated_data)
        if password is not None:
            instance.set_password(password)
        instance.save()
        return instance


class UserSerializer(serializers.ModelSerializer):
     class Meta:
        model = User
        fields = ["id", "username", "email", "first_name", "last_name"]


class GymSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Gym
        fields = ["id", "name", "country", "city", "address"]


class GymAdminSerializer(serializers.ModelSerializer):
    first_name = serializers.CharField(source="user.first_name", read_only=True)
    last_name = serializers.CharField(source="user.last_name", read_only=True)
    user_id = serializers.CharField(source="user.user_id", read_only=True)
    gym_name = serializers.CharField(source="gym.name", read_only=True)

    class Meta:
        model = models.GymAdmin
        fields = [
            "id",
            "user",
            "gym",
            "isAdmin",
            "isTrainer",
            "isUser",
            "first_name",
            "last_name",
            "user_id",
            "gym_name",
        ]


class GymTrainerSerializer(serializers.ModelSerializer):
    first_name = serializers.CharField(source="user.first_name", read_only=True)
    last_name = serializers.CharField(source="user.last_name", read_only=True)
    gym_name = serializers.CharField(source="gym.name", read_only=True)
    email = serializers.CharField(source="user.email", read_only=True)
    username = serializers.CharField(source="user.username", read_only=True)

    class Meta:
        model = models.GymTrainer
        fields = [
            "id",
            "user",
            "first_name",
            "last_name",
            "gym",
            "isAdmin",
            "isTrainer",
            "isUser",
            "gym_name",
            "contact",
            "email",
            "username",
            "certification",
            "monthly_charges",
        ]


class GymUserSerializer(serializers.ModelSerializer):
    first_name = serializers.CharField(source="user.first_name", read_only=True)
    last_name = serializers.CharField(source="user.last_name", read_only=True)
    gym_name = serializers.CharField(source="gym.name", read_only=True)
    gym_id = serializers.CharField(source="gym.id", read_only=True)

    # user_contact = serializers.CharField(source='user.contact', read_only=True)
    email = serializers.CharField(source="user.email", read_only=True)
    username = serializers.CharField(source="user.username", read_only=True)
    trainer_firstName = serializers.CharField(
        source="trainer.user.first_name", read_only=True
    )
    trainer_lastName = serializers.CharField(
        source="trainer.user.last_name", read_only=True
    )
    trainer_id = serializers.CharField(source="trainer.user.id", read_only=True)

    trainer_certification = serializers.CharField(
        source="trainer.certfication", read_only=True
    )
    
    first_name = serializers.CharField(source="user.first_name", required=False)
    last_name = serializers.CharField(source="user.last_name", required=False)
    email = serializers.EmailField(source="user.email", required=False)
    contact = serializers.CharField(required=False, allow_blank=True)
    trainer = serializers.PrimaryKeyRelatedField(queryset=models.GymTrainer.objects.all(), required=False, allow_null=True)

    class Meta:
        model = models.GymUser
        fields = [
            "id",
            "user",
            "gym",
            "gym_id",
            "isAdmin",
            "isTrainer",
            "isUser",
            "first_name",
            "last_name",
            "gym_name",
            "contact",
            "email",
            "username",
            "trainer_firstName",
            "trainer_lastName",
            "trainer_id",
            "number_of_tokens",
            "trainerSelected",
            "trainer_certification",
            "membership",
            "trainer"
        ]
    # def update(self, instance, validated_data):
    #     print(validated_data)
        
    #     return instance
    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        trainer_data = validated_data.pop('trainer', None)
        print(validated_data)
        print(trainer_data)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if user_data:
            user = instance.user
            for attr, value in user_data.items():
                setattr(user, attr, value)
            user.save()

        instance.trainer = trainer_data
        instance.trainerSelected = True
        instance.save()
        return instance
    
class RegisterUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    email = serializers.EmailField(
        required=True, validators=[UniqueValidator(queryset=User.objects.all())]
    )
    username = serializers.CharField(
        required=True, validators=[UniqueValidator(queryset=User.objects.all())]
    )

    class Meta:
        model = User
        fields = ("username", "email", "password", "first_name", "last_name")

    def create(self, validated_data):
        trainerSelected = False
        gym_id = self.context.get("gym_id")
        contact = self.context.get("contact")
        trainer_id = self.context.get("trainer")

        print("Gym ID : " + gym_id + " | " + "Contact : " + contact + " | ")
        print("Trainer ID Below :" + trainer_id)

        user = User.objects.create(
            username=validated_data["username"],
            email=validated_data["email"],
            first_name=validated_data["first_name"],
            last_name=validated_data["last_name"],
        )
        user.set_password(validated_data["password"])
        user.save()
        if trainer_id == "No Trainer":
            trainerSelected = False
        else:
            trainerSelected = True
            try:
                trainer_user = models.User.objects.get(pk=trainer_id)
            except models.User.DoesNotExist:
                raise serializers.ValidationError("Invalid Trainer ID")
            try:
                trainer = models.GymTrainer.objects.get(user=trainer_user)
            except models.GymTrainer.DoesNotExist:
                raise serializers.ValidationError("Invalid Trainer ID")

        try:
            gym = models.Gym.objects.get(pk=gym_id)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Gym ID")
        if trainerSelected == True:
            gym_user = models.GymUser.objects.create(
                user=user,
                gym=gym,
                contact=contact,
                trainer=trainer,
                trainerSelected=trainerSelected,
            )
        else:
            gym_user = models.GymUser.objects.create(
                user=user, gym=gym, contact=contact, trainerSelected=trainerSelected
            )
        gym_user.save()
        return user


class RegisterTrainerSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    email = serializers.EmailField(
        required=True, validators=[UniqueValidator(queryset=User.objects.all())]
    )
    username = serializers.CharField(
        required=True, validators=[UniqueValidator(queryset=User.objects.all())]
    )

    class Meta:
        model = User
        fields = ("id", "username", "email", "password", "first_name", "last_name")

    def create(self, validated_data):
        gym_id = self.context.get("gym_id")
        contact = self.context.get("contact")
        certification = self.context.get("certification")
        monthly_charges = self.context.get("monthly_charges")
        print(
            "Gym ID : "
            + gym_id
            + " | "
            + "Contact : "
            + contact
            + " | "
            + "Certification : "
            + certification
        )
        user = User.objects.create(
            username=validated_data["username"],
            email=validated_data["email"],
            first_name=validated_data["first_name"],
            last_name=validated_data["last_name"],
        )
        user.set_password(validated_data["password"])
        user.save()
        try:
            gym = models.Gym.objects.get(pk=gym_id)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Gym ID")

        gym_trainer = models.GymTrainer.objects.create(
            user=user,
            gym=gym,
            contact=contact,
            certification=certification,
            monthly_charges=monthly_charges,
        )
        gym_trainer.save()
        return user


class AddEquipmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.GymEquipments
        fields = ("id", "name", "category", "description", "quantity")

    def create(self, validated_data):
        gym_id = self.context.get("gym_id")
        equipment_name = validated_data["name"]
        equipment_category = validated_data["category"]
        equipment_quantity = validated_data["quantity"]
        equipment_description = validated_data["description"]

        print(
            "Equipment validate data = "
            + " "
            + equipment_name
            + " "
            + str(equipment_quantity)
            + " "
            + equipment_category
            + " "
            + equipment_description
            + " "
            + gym_id
        )
        try:
            gym = models.Gym.objects.get(pk=gym_id)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Gym ID")

        equipment = models.GymEquipments.objects.create(
            gym=gym,
            name=equipment_name,
            category=equipment_category,
            quantity=equipment_quantity,
            description=equipment_description,
        )

        return equipment


class GymEquipmentSerializer(serializers.ModelSerializer):
    gym_name = serializers.CharField(source="gym.name", read_only=True)

    class Meta:
        model = models.GymEquipments
        fields = [
            "name",
            "category",
            "description",
            "quantity",
            "gym_name",
        ]


class AddExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Exercise
        fields = "__all__"

    def create(self, validated_data):
        # gym_id = self.context.get("gym_id")
        exercise_name = validated_data["name"]
        exercise_image = validated_data["image"]
        exercise_type = validated_data["exercise_type"]
        exercise_description = validated_data["description"]

        print(
            "Equipment validate data = "
            + " "
            + exercise_name
            + " "
            + str(exercise_type)
            + " "
            # + str(exercise_image)
            # + " "
            + exercise_description
        )
        exercise = models.Exercise.objects.create(
            # gym=gym,
            name=exercise_name,
            exercise_type=exercise_type,
            image=exercise_image,
            description=exercise_description,
        )

        return exercise


class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Attendance
        fields = "__all__"


class GymExerciseSerializer(serializers.ModelSerializer):
    # gym_name = serializers.CharField(source="gym.name", read_only=True)

    class Meta:
        model = models.Exercise
        fields = "__all__"


class AddGymTokenPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.GymTokenPlans
        fields = (
            "name",
            "description",
            "number_of_tokens",
            "duration_of_months",
            "plan_price",
        )

    def create(self, validated_data):
        gym_id = self.context.get("gym_id")
        name = validated_data["name"]
        description = validated_data["description"]
        number_of_tokens = validated_data["number_of_tokens"]
        plan_price = validated_data["plan_price"]
        duration_of_months = validated_data["duration_of_months"]

        print(
            "Equipment validate data = "
            + " "
            + name
            + " "
            + str(number_of_tokens)
            + " "
            + str(plan_price)
            + " "
            + gym_id
            + " "
            + description
            + " "
            + str(duration_of_months)
        )

        try:
            gym = models.Gym.objects.get(pk=gym_id)
        except models.Gym.DoesNotExist:
            raise serializers.ValidationError("Invalid Gym ID")

        token_plan = models.GymTokenPlans.objects.create(
            gym=gym,
            name=name,
            number_of_tokens=number_of_tokens,
            duration_of_months=duration_of_months,
            description=description,
            plan_price=plan_price,
        )

        return token_plan


class GymTokenPlanSerializer(serializers.ModelSerializer):
    gym_name = serializers.CharField(source="gym.name", read_only=True)

    class Meta:
        model = models.GymTokenPlans
        fields = [
            "id",
            "gym_name",
            "name",
            "description",
            "number_of_tokens",
            "duration_of_months",
            "plan_price",
        ]


class AddGymPurchaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.GymPurchases
        fields = (
            "gym_user",
            "gym",
            "number_of_tokens",
            "start_date",
            "end_date",
            "price",
        )

    def create(self, validated_data):
        gym_id = self.context.get("gym_id")
        gym_user_id = self.context.get("gym_user_id")
        token_plan_id = self.context.get("token_plan_id")
        number_of_tokens = self.context.get("number_of_tokens")
        plan_price = self.context.get("plan_price")
        start_date = self.context.get("start_date")
        end_date = self.context.get("end_date")
        # try:
        #     gym = models.Gym.objects.get(pk=gym_id)
        # except models.Gym.DoesNotExist:
        #     raise serializers.ValidationError("Invalid Gym ID")
        # try:
        #     plan = models.GymTokenPlans.objects.get(pk=token_plan_id)
        # except models.Gym.DoesNotExist:
        #     raise serializers.ValidationError("Invalid Plan ID")
        # try:
        #     gym_user = models.GymUser.objects.get(pk=gym_user_id)
        # except models.Gym.DoesNotExist:
        #     raise serializers.ValidationError("Invalid Gym User ID")

        # gym_user.add_tokens(number_of_tokens,0)

        # # start_date = datetime.now().date()
        # # end_date = start_date + timedelta(days=30)

        # token_plan = models.GymPurchases.objects.create(
        #     gym=gym,
        #     gym_user = gym_user,
        #     token_plan = plan,
        #     number_of_tokens=number_of_tokens,
        #     price=plan_price,
        #     start_date = start_date,
        #     end_date=end_date
        # )

        return token_plan


class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = "__all__"


class DietPlanDaySerializer(serializers.ModelSerializer):
    class Meta:
        model = DietPlanDay
        fields = ["id", "day", "breakfast", "lunch", "dinner", "snacks"]


class DietPlanSerializer(serializers.ModelSerializer):
    days = DietPlanDaySerializer(many=True)
    trainer_id = serializers.PrimaryKeyRelatedField(
        queryset=GymTrainer.objects.all(), source="trainer"
    )
    trainees = GymUserSerializer(many=True, read_only=True)

    class Meta:
        model = DietPlan
        fields = [
            "id",
            "name",
            "description",
            "created_at",
            "updated_at",
            "trainer_id",
            "trainees",
            "days",
        ]

    def create(self, validated_data):
        days_data = validated_data.pop("days", [])
        trainees = validated_data.pop("trainees", [])
        diet_plan = DietPlan.objects.create(**validated_data)
        diet_plan.trainees.set(trainees)

        for day_data in days_data:
            DietPlanDay.objects.create(diet_plan=diet_plan, **day_data)

        return diet_plan

    def update(self, instance, validated_data):
        plan_id = self.context.get("plan_id")
        days_data = self.context.get("days_data")
        trainees_data = self.context.get("trainees")
        print("days data ", days_data)
        print("trainees", trainees_data)

        trainees = validated_data.pop("trainees", None)
        instance.name = validated_data.get("name", instance.name)
        instance.description = validated_data.get("description", instance.description)
        instance.trainer = validated_data.get("trainer", instance.trainer)
        if trainees_data is not None:
            instance.trainees.set(trainees_data)
        if days_data is not None:
            for day_data in days_data:
                day_id = day_data.get("id")
                if day_id is not None:
                    day_instance = DietPlanDay.objects.get(id=day_id)
                    day_instance.day = day_data.get("day", day_instance.day)
                    day_instance.breakfast = day_data.get(
                        "breakfast", day_instance.breakfast
                    )
                    day_instance.lunch = day_data.get("lunch", day_instance.lunch)
                    day_instance.dinner = day_data.get("dinner", day_instance.dinner)
                    day_instance.snacks = day_data.get("snacks", day_instance.snacks)

                    day_instance.save()
                elif day_id is None:

                    print("day data", day_data)
                    DietPlanDay.objects.create(diet_plan=instance, **day_data).save()

        instance.save()
        return instance


from rest_framework import serializers
from .models import WorkoutPlan, WorkoutPlanDay, Exercise, GymTrainer, GymUser

class WorkoutPlanDaySerializer(serializers.ModelSerializer):
    exercises = AddExerciseSerializer(many=True, read_only=True)
    exercise_ids = serializers.PrimaryKeyRelatedField(
        queryset=Exercise.objects.all(), source='exercises', many=True, write_only=True
    )

    class Meta:
        model = WorkoutPlanDay
        fields = ['id', 'workout_name', 'day', 'exercises', 'exercise_ids']

class WorkoutPlanSerializer(serializers.ModelSerializer):
    Workout_plan_days = WorkoutPlanDaySerializer(many=True, read_only=True)
    trainees = GymUserSerializer(many=True, read_only=True)

    class Meta:
        model = WorkoutPlan
        fields = ['id', 'trainer', 'name', 'description', 'created_at', 'updated_at', 'Workout_plan_days', 'trainees']

    def create(self, validated_data):
        # days_data = validated_data.pop('days', [])
        days_data = self.context.get('workout_day_data')
        trainees_data = validated_data.pop('trainees', [])
        workout_plan = WorkoutPlan.objects.create(**validated_data)
        workout_plan.trainees.set(trainees_data)
        for day_data in days_data:
            exercises_data = day_data.pop('exercises', [])
            
            print(exercises_data)
            workout_plan_day = WorkoutPlanDay.objects.create(workout_plan=workout_plan, **day_data)
            workout_plan_day.exercises.set(exercises_data)
        return workout_plan

    def update(self, instance, validated_data):
        
        print(validated_data)
        # days_data = validated_data.pop('Workout_plan_days')
        days_data = self.context.get('workout_plan_data')
        trainees_data = self.context.get('trainees')
        print(days_data)
        print(trainees_data);
        instance.name = validated_data.get('name', instance.name)
        instance.description = validated_data.get('description', instance.description)
        instance.trainer = validated_data.get('trainer', instance.trainer)
        instance.save()

        instance.trainees.set(trainees_data)

        instance.Workout_plan_days.all().delete()
        for day_data in days_data:
            print(day_data);
            exercises_data = day_data.pop('exercises')
            workout_plan_day = WorkoutPlanDay.objects.create(workout_plan=instance, **day_data)
            workout_plan_day.exercises.set(exercises_data)

        return instance
    
class PersonalGoalSerializer(serializers.ModelSerializer):
    gym_user = serializers.IntegerField(write_only=True)  # Expecting gym_user ID

    class Meta:
        model = PersonalGoal
        fields = ['id', 'goal_type', 'target_value', 'start_date', 'end_date', 'gym_user']
    

class WeeklyProgressSerializer(serializers.ModelSerializer):
    progress_percentage = serializers.SerializerMethodField()

    class Meta:
        model = models.WeeklyProgress
        fields = '__all__'

    def get_progress_percentage(self, obj):
        return obj.progress_percentage()

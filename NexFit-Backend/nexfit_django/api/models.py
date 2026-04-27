from django.db import models
from django.contrib.auth import models as auth_models
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.models import User
from django.utils import timezone

def upload_to(instance, filename):
    return 'images/{filename}'.format(filename=filename)


class Gym(models.Model):
    name = models.CharField(max_length=255, verbose_name="Gym Name", unique=True)
    country = models.CharField(max_length=255, verbose_name="Country")
    city = models.CharField(max_length=255, verbose_name="City Name")
    address = models.CharField(max_length=255, verbose_name="Address")

    def __str__(self):
        return self.name

class AttendanceToken(models.Model):
    gym = models.ForeignKey(Gym, blank=True, null=True, on_delete=models.CASCADE)
    price = models.DecimalField(max_digits = 10,decimal_places=2)
    currency = models.CharField(max_length=20)
    def __str__(self):
        return self.gym.name + " - " + str(self.price) + " - " + str(self.currency)

class GymAdmin(models.Model):
    user = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE)
    isAdmin = models.BooleanField(default=True)
    isTrainer = models.BooleanField(default=False)
    isUser = models.BooleanField(default=False, null=False)

    def __str__(self):
        return self.user.first_name + " - " + self.gym.name


class GymTrainer(models.Model):
    user = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE)
    contact = models.CharField(max_length=15, null=True, blank=True)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE)
    isAdmin = models.BooleanField(default=False)
    isTrainer = models.BooleanField(default=True)
    isUser = models.BooleanField(default=False, null=False)
    monthly_charges = models.IntegerField(null=True, blank=True)
    certification = models.CharField(max_length=1000, null=True, blank=True)
    available = models.BooleanField(default = True)
    def __str__(self):
        return str(self.user.id)

    def get_trainees(self):
        return self.trainees.all()


class GymUser(models.Model):
    membership_choices = [
        ('active','Active'),
        ('pending','Pending'),
        ('cancelled','Cancelled'),
    ]
    user = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE)
    contact = models.CharField(max_length=15)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE)
    trainerSelected = models.BooleanField(default=False, blank=True, null=True)
    trainer = models.ForeignKey(
        GymTrainer,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="trainees",
    )
    isAdmin = models.BooleanField(default=False)
    isTrainer = models.BooleanField(default=False)
    isUser = models.BooleanField(default=True, null=False)
    number_of_tokens = models.PositiveIntegerField(default=0)
    membership = models.CharField(max_length=255,choices=membership_choices, default= membership_choices[0])
    def __str__(self):
        return self.user.first_name + " - " + self.gym.name + " Number of Token = " + str(self.number_of_tokens) + " "+ str(self.trainerSelected)
    
    def add_tokens(self, quantity):
        self.number_of_tokens += quantity
        self.save()

class GymUserToken(models.Model):
    gym_user = models.ForeignKey(GymUser,on_delete=models.CASCADE)
    token = models.ForeignKey(AttendanceToken, on_delete=models.CASCADE)
    quantity = models.IntegerField(default=0)
    
    def __str__(self):
        return self.gym_user.user.first_name + " - " + self.token.gym.name + " - " +str(self.token.price) + " - " +str(self.quantity)
    

class GymEquipments(models.Model):
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE)
    name = models.CharField(max_length=255, null=True, blank=True)
    category = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    quantity = models.PositiveIntegerField(default=0)
    
    def __str__(self):
        return self.name
    
class Exercise(models.Model):
    name = models.CharField(max_length=255)
    exercise_type = models.CharField(max_length=255,null=True, blank=True)
    image = models.ImageField(null=True, blank=True, upload_to=upload_to)
    description = models.TextField(null=True, blank=True)
    
    def __str__(self):
        return self.name + " | " + self.exercise_type
    
    
class GymTokenPlans(models.Model):
    gym = models.ForeignKey(Gym,on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    plan_price = models.PositiveIntegerField()
    number_of_tokens = models.PositiveIntegerField()
    description = models.TextField(blank=True,null=True)
    duration_of_months = models.PositiveIntegerField()
    
    def __str__(self):
        return self.name + " " + str(self.plan_price) + " " + str(self.number_of_tokens)

class GymPurchases(models.Model):
    gym_user = models.ForeignKey(GymUser,on_delete=models.CASCADE)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE)
    token_plan = models.ForeignKey(GymTokenPlans,on_delete=models.CASCADE)
    number_of_tokens = models.PositiveIntegerField()
    price = models.PositiveIntegerField()
    start_date = models.DateField()
    end_date = models.DateField()
    
    def __str__(self):
        return str(self.start_date) + " " + str(self.end_date)

class Attendance(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField(default=timezone.now)
    class Meta:
        unique_together = ('user', 'date')

    def __str__(self):
        return f"Attendance for {self.user.username} on {self.date}"

class Message(models.Model):
    
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages', null=True)
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages', null=True)
    message = models.TextField(null=True)
    timestamp = models.DateTimeField(auto_now_add=True, null=True)

    def __str__(self):
        return str(self.sender) + " and " + str(self.receiver)
    
class DietPlan(models.Model):
    trainer = models.ForeignKey('GymTrainer', on_delete=models.CASCADE, related_name="diet_plans")
    trainees = models.ManyToManyField('GymUser', related_name="diet_plans")
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class DietPlanDay(models.Model):
    DIET_DAYS = [
        ('day_1', 'Day 1'),
        ('day_2', 'Day 2'),
        ('day_3', 'Day 3'),
        ('day_4', 'Day 4'),
        ('day_5', 'Day 5'),
        ('day_6', 'Day 6'),
        ('day_7', 'Day 7'),
    ]
    
    diet_plan = models.ForeignKey(DietPlan, on_delete=models.CASCADE, related_name="days")
    day = models.CharField(max_length=10, choices=DIET_DAYS)
    breakfast = models.TextField(null=True, blank=True)
    lunch = models.TextField(null=True, blank=True)
    dinner = models.TextField(null=True, blank=True)
    snacks = models.TextField(null=True, blank=True)

    class Meta:
        unique_together = ('diet_plan', 'day')

    def __str__(self):
        return f"{self.diet_plan.name} - {self.get_day_display()}"


class WorkoutPlan(models.Model):
    trainer = models.ForeignKey('GymTrainer', on_delete=models.CASCADE, related_name="workout_plans")
    trainees = models.ManyToManyField('GymUser', related_name="workout_plans")
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class WorkoutPlanDay(models.Model):
    WORKOUT_DAYS = [
        ('day_1', 'Day 1'),
        ('day_2', 'Day 2'),
        ('day_3', 'Day 3'),
        ('day_4', 'Day 4'),
        ('day_5', 'Day 5'),
        ('day_6', 'Day 6'),
        ('day_7', 'Day 7'),
    ]
    workout_name =models.CharField(max_length=10, blank=True, null=True)
    workout_plan = models.ForeignKey(WorkoutPlan, on_delete=models.CASCADE, related_name="Workout_plan_days")
    day = models.CharField(max_length=10, choices=WORKOUT_DAYS)
    exercises = models.ManyToManyField('Exercise', related_name='workout_plan_exercises')

    class Meta:
        unique_together = ('workout_plan', 'day')

    def __str__(self):
        return f"{self.workout_plan.name} - {self.get_day_display()}"

class PersonalGoal(models.Model):
    GOAL_TYPES = [
        ('weight_gain', 'Weight Gain'),
        ('weight_loss', 'Weight Loss'),
        ('bmi', 'BMI')
    ]

    gym_user = models.ForeignKey(GymUser, on_delete=models.CASCADE, related_name='personal_goals')
    goal_type = models.CharField(max_length=20, choices=GOAL_TYPES)
    target_value = models.FloatField(help_text='Target weight or BMI')
    start_date = models.DateField(default=timezone.now)
    end_date = models.DateField(help_text='Target date to achieve goal')

    def __str__(self):
        return f"{self.gym_user.user.username} - {self.get_goal_type_display()} Goal: {self.target_value}"

class WeeklyProgress(models.Model):
    personal_goal = models.ForeignKey(PersonalGoal, on_delete=models.CASCADE, related_name='weekly_progresses')
    date = models.DateField(default=timezone.now)
    current_value = models.FloatField(help_text='Current weight or BMI')

    def __str__(self):
        return f"{self.personal_goal.gym_user.user.username} - Progress: {self.current_value} on {self.date}"

    def progress_percentage(self):
        initial_progress = self.personal_goal.weekly_progresses.order_by('date').first().current_value
        target_value = self.personal_goal.target_value

        if self.personal_goal.goal_type == 'weight_loss':
            progress = (initial_progress - self.current_value) / (initial_progress - target_value)
        else:
            progress = (self.current_value - initial_progress) / (target_value - initial_progress)

        return round(progress * 100, 2)


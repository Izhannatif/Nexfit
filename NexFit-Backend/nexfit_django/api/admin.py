from django.contrib import admin
from . import models
@admin.register(models.GymAdmin)
class GymAdmin(admin.ModelAdmin):
    list_display = ('user', 'gym')
    search_fields = ('user__username','gym__name',)
    
admin.site.register(models.Gym)
admin.site.register(models.GymUser)
admin.site.register(models.GymTrainer)
admin.site.register(models.AttendanceToken)
admin.site.register(models.GymUserToken)
admin.site.register(models.GymEquipments)
admin.site.register(models.Exercise)
admin.site.register(models.GymTokenPlans)
admin.site.register(models.GymPurchases)
admin.site.register(models.Message)
admin.site.register(models.Attendance)
admin.site.register(models.DietPlan)
admin.site.register(models.DietPlanDay)
admin.site.register(models.WorkoutPlan)
admin.site.register(models.WorkoutPlanDay)
admin.site.register(models.PersonalGoal)
admin.site.register(models.WeeklyProgress)

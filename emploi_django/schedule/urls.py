from django.urls import path
from . import views

urlpatterns = [
    path('', views.schedule_view, name='schedule'),
    path('plan/', views.plan_view, name='plan'),
    path('database/', views.CourseListView.as_view(), name='database'),
    
    # API endpoints
    path('api/courses/', views.get_courses, name='api_courses'),
    path('api/course/<str:code>/', views.get_course_info, name='api_course_info'),
    path('api/professors/', views.get_professors, name='api_professors'),
    path('api/rooms/', views.get_rooms, name='api_rooms'),
    path('api/schedule/<int:week>/', views.get_schedule, name='api_schedule'),
    path('api/plan/all/', views.get_all_plan, name='api_plan_all'),
    path('api/plan/<int:week>/', views.get_plan, name='api_plan'),
    path('api/plan/save/', views.save_plan, name='api_save_plan'),
    path('update_course/', views.update_course, name='update_course'),
    path('delete_course/', views.delete_course, name='delete_course'),
     path('bilan/', views.bilan_view, name='bilan'),
    path('api/update_bilan/', views.update_bilan, name='update_bilan'),

]

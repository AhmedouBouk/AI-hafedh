from django.urls import path
from . import views

urlpatterns = [
    path('', views.schedule_view, name='schedule'),
    path('plan/', views.plan_view, name='plan'),
    path('database/', views.CourseListView.as_view(), name='database'),
    path('bilan/', views.bilan_view, name='bilan'),
    path('update-bilan/', views.update_bilan, name='update_bilan'),
    path('delete-course/', views.delete_course, name='delete_course'),
    path('add-course/', views.add_course, name='add_course'),
    path('update-course/', views.update_course, name='update_course'),
    
    # Professors URLs
    path('professors/', views.professors_view, name='professors'),
    path('add-professor/', views.add_professor, name='add_professor'),
    path('update-professor/', views.update_professor, name='update_professor'),
    path('delete-professor/', views.delete_professor, name='delete_professor'),
    
    # Rooms URLs
    path('rooms/', views.rooms_view, name='rooms'),
    path('add-room/', views.add_room, name='add_room'),
    path('update-room/', views.update_room, name='update_room'),
    path('delete-room/', views.delete_room, name='delete_room'),
    
    # API URLs
    path('api/courses/', views.get_courses, name='get_courses'),
    path('api/course/<str:code>/', views.get_course_info, name='get_course_info'),
    path('api/professors/', views.get_professors, name='get_professors'),
    path('api/rooms/', views.get_rooms, name='get_rooms'),
    path('api/schedule/<int:week>/', views.get_schedule, name='get_schedule'),
    path('api/plan/all/', views.get_all_plan, name='get_all_plan'),
    path('api/plan/<int:week>/', views.get_plan, name='get_plan'),
    path('api/plan/save/', views.save_plan, name='save_plan'),
]

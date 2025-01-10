from django.shortcuts import render
from django.views.generic import ListView
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
import json
from .models import Course, Professor, Room, CourseAssignment, TimeSlot

def schedule_view(request):
    """View for displaying the weekly schedule"""
    context = {
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 18),  # S1 to S17
    }
    return render(request, 'schedule/schedule.html', context)

def plan_view(request):
    """View for managing the schedule plan"""
    context = {
        'days': TimeSlot.DAYS,
        'periods': TimeSlot.PERIODS,
        'weeks': range(1, 18),
    }
    return render(request, 'schedule/plan.html', context)

class CourseListView(ListView):
    """View for displaying and managing the course database"""
    model = Course
    template_name = 'schedule/database.html'
    context_object_name = 'courses'

# API Views
def get_courses(request):
    """Get all courses"""
    courses = Course.objects.all()
    data = [{
        'code': course.code,
        'title': course.title
    } for course in courses]
    return JsonResponse(data, safe=False)

@csrf_exempt
def get_course_info(request, code):
    """Get, update, or delete course information"""
    try:
        if request.method == 'GET':
            course = Course.objects.get(pk=code)
            assignments = CourseAssignment.objects.filter(course=course)
            data = {
                'code': course.code,
                'title': course.title,
                'credits': course.credits,
                'cm_hours': course.cm_hours,
                'td_hours': course.td_hours,
                'tp_hours': course.tp_hours,
                'professors': {
                    'CM': assignments.filter(type='CM').first().professor.id if assignments.filter(type='CM').exists() else None,
                    'TD': assignments.filter(type='TD').first().professor.id if assignments.filter(type='TD').exists() else None,
                    'TP': assignments.filter(type='TP').first().professor.id if assignments.filter(type='TP').exists() else None,
                },
                'rooms': {
                    'CM': assignments.filter(type='CM').first().room.id if assignments.filter(type='CM').exists() and assignments.filter(type='CM').first().room else None,
                    'TD': assignments.filter(type='TD').first().room.id if assignments.filter(type='TD').exists() and assignments.filter(type='TD').first().room else None,
                    'TP': assignments.filter(type='TP').first().room.id if assignments.filter(type='TP').exists() and assignments.filter(type='TP').first().room else None,
                }
            }
            return JsonResponse(data)
            
        elif request.method == 'POST' or request.method == 'PUT':
            data = json.loads(request.body)
            course, created = Course.objects.update_or_create(
                code=code,
                defaults={
                    'title': data['title'],
                    'credits': data['credits'],
                    'cm_hours': data['cm_hours'],
                    'td_hours': data['td_hours'],
                    'tp_hours': data['tp_hours'],
                }
            )
            
            # Update assignments
            for type_key in ['CM', 'TD', 'TP']:
                if data['professors'].get(type_key):
                    professor = Professor.objects.get(id=data['professors'][type_key])
                    room = Room.objects.get(id=data['rooms'][type_key]) if data['rooms'].get(type_key) else None
                    CourseAssignment.objects.update_or_create(
                        course=course,
                        type=type_key,
                        defaults={
                            'professor': professor,
                            'room': room
                        }
                    )
            
            return JsonResponse({'status': 'success'})
            
        elif request.method == 'DELETE':
            course = Course.objects.get(pk=code)
            course.delete()
            return JsonResponse({'status': 'success'})
            
    except ObjectDoesNotExist:
        return JsonResponse({'error': 'Course not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def get_professors(request):
    """Get all professors"""
    professors = Professor.objects.all()
    data = [{
        'id': prof.id,
        'name': prof.name
    } for prof in professors]
    return JsonResponse(data, safe=False)

def get_rooms(request):
    """Get all rooms"""
    rooms = Room.objects.all()
    data = [{
        'id': room.id,
        'number': room.number,
        'type': room.type
    } for room in rooms]
    return JsonResponse(data, safe=False)

def get_schedule(request, week):
    """Get schedule for a specific week"""
    slots = TimeSlot.objects.filter(week=week)
    data = [{
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type,
        'professor': slot.course_assignment.professor.name,
        'room': slot.course_assignment.room.number if slot.course_assignment.room else None
    } for slot in slots]
    return JsonResponse(data, safe=False)

def get_all_plan(request):
    """Get plan for all weeks"""
    slots = TimeSlot.objects.all()
    data = [{
        'week': slot.week,
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type
    } for slot in slots]
    return JsonResponse(data, safe=False)

@csrf_exempt
def get_plan(request, week):
    """Get plan for a specific week"""
    slots = TimeSlot.objects.filter(week=week)
    data = [{
        'day': slot.day,
        'period': slot.period,
        'course_code': slot.course_assignment.course.code,
        'type': slot.course_assignment.type
    } for slot in slots]
    return JsonResponse(data, safe=False)

@csrf_exempt
def save_plan(request):
    """Save schedule plan"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            plan = data['plan']
            
            # Clear existing slots for the week
            week = plan[0]['week'] if plan else None
            if week is not None:
                TimeSlot.objects.filter(week=week).delete()
            
            # Create new slots
            for item in plan:
                course = Course.objects.get(code=item['course_code'])
                assignment = CourseAssignment.objects.get(
                    course=course,
                    type=item['type']
                )
                TimeSlot.objects.create(
                    week=item['week'],
                    day=item['day'],
                    period=item['period'],
                    course_assignment=assignment
                )
            
            return JsonResponse({'status': 'success'})
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    
    return JsonResponse({'error': 'Invalid request method'}, status=405)

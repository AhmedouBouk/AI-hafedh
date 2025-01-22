from django import template

register = template.Library()

@register.filter
def first_with_course(course_assignments, course):
    """
    Retourne la première assignation de cours correspondant à un cours donné.
    """
    return course_assignments.filter(course=course).first()
from django import template
from django.core import serializers
import json

register = template.Library()

@register.filter
def to_json(value):
    return serializers.serialize('json', value)
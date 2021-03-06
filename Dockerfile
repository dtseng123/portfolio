FROM python:latest

ENV PYTHONUNBUFFERED 1

# Set the Django settings to use.
ENV DJANGO_ENV "dev"
ENV DJANGO_SETTINGS_MODULE "portfolio.settings.dev"

# Install a WSGI server into the container image.
RUN pip install waitress

# Code will end up living in /app/
WORKDIR /app/

# Copy and install the project requirements.
COPY ./requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Copy the entire project code.
COPY . /app/

# Prepare the app.
RUN python manage.py migrate
RUN python manage.py collectstatic --noinput

# Create a "coderedcms" user account to run the app.
RUN useradd coderedcms
RUN chown -R coderedcms /app/
USER coderedcms

# Finally, run the app on port 8000.
EXPOSE 8000
CMD exec waitress-serve --listen "*:8000" "portfolio.wsgi:application"

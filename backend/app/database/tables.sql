-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.bookings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainer_id uuid NOT NULL,
  user_id uuid NOT NULL,
  session_time timestamp with time zone NOT NULL,
  price numeric,
  status character varying NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.users(id),
  CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.buddies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  requester_id uuid NOT NULL,
  requestee_id uuid NOT NULL,
  status character varying NOT NULL DEFAULT 'requested'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT buddies_pkey PRIMARY KEY (id),
  CONSTRAINT buddies_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.users(id),
  CONSTRAINT buddies_requestee_id_fkey FOREIGN KEY (requestee_id) REFERENCES public.users(id)
);
CREATE TABLE public.challenge_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  challenge_id uuid NOT NULL,
  user_id uuid NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'joined'::participant_status_enum,
  progress numeric NOT NULL DEFAULT 0.0 CHECK (progress >= 0::numeric),
  progress_percentage numeric NOT NULL DEFAULT 0.0 CHECK (progress_percentage >= 0::numeric AND progress_percentage <= 100::numeric),
  completion_proof_url text,
  joined_at timestamp with time zone NOT NULL DEFAULT now(),
  completed_at timestamp with time zone,
  notes text,
  CONSTRAINT challenge_participants_pkey PRIMARY KEY (id),
  CONSTRAINT challenge_participants_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id),
  CONSTRAINT challenge_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.challenge_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying NOT NULL,
  description text NOT NULL,
  start_date timestamp with time zone NOT NULL,
  duration_days integer NOT NULL,
  cover_image_url text,
  participant_count integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT challenge_posts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.challenge_updates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  participant_id uuid NOT NULL,
  previous_progress numeric NOT NULL,
  new_progress numeric NOT NULL,
  update_description text,
  proof_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT challenge_updates_pkey PRIMARY KEY (id),
  CONSTRAINT challenge_updates_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.challenge_participants(id)
);
CREATE TABLE public.challenges (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying NOT NULL,
  description text,
  brand character varying,
  brand_logo text,
  background_image text,
  distance numeric CHECK (distance IS NULL OR distance > 0::numeric),
  duration integer CHECK (duration IS NULL OR duration > 0),
  start_date timestamp with time zone NOT NULL,
  end_date timestamp with time zone NOT NULL,
  activity_type USER-DEFINED NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'draft'::challenge_status_enum,
  brand_color character varying,
  max_participants integer CHECK (max_participants IS NULL OR max_participants > 0),
  is_public boolean NOT NULL DEFAULT true,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT challenges_pkey PRIMARY KEY (id),
  CONSTRAINT challenges_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);
CREATE TABLE public.comments (
  id uuid NOT NULL,
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  CONSTRAINT comments_pkey PRIMARY KEY (id),
  CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.communities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  creator_user_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  image_url text,
  is_private boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  member_count integer DEFAULT 0 CHECK (member_count >= 0),
  community_status character varying NOT NULL CHECK (community_status::text = ANY (ARRAY['active'::character varying, 'restricted'::character varying]::text[])),
  CONSTRAINT communities_pkey PRIMARY KEY (id),
  CONSTRAINT communities_creator_user_id_fkey FOREIGN KEY (creator_user_id) REFERENCES public.users(id)
);
CREATE TABLE public.community_members (
  community_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role USER-DEFINED NOT NULL DEFAULT 'member'::community_member_role_enum,
  joined_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT community_members_pkey PRIMARY KEY (user_id, community_id),
  CONSTRAINT community_members_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.communities(id),
  CONSTRAINT community_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.community_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  community_id uuid NOT NULL,
  user_id uuid NOT NULL,
  content text NOT NULL,
  attachments jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT community_messages_pkey PRIMARY KEY (id),
  CONSTRAINT community_messages_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.communities(id),
  CONSTRAINT community_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.completed_workout_exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  completed_workout_id uuid NOT NULL,
  exercise_id character varying NOT NULL,
  exercise_name character varying NOT NULL,
  exercise_equipments ARRAY,
  exercise_gif_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT completed_workout_exercises_pkey PRIMARY KEY (id),
  CONSTRAINT completed_workout_exercises_completed_workout_id_fkey FOREIGN KEY (completed_workout_id) REFERENCES public.completed_workouts(id)
);
CREATE TABLE public.completed_workout_sets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  completed_workout_exercise_id uuid NOT NULL,
  weight character varying NOT NULL,
  reps character varying NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT completed_workout_sets_pkey PRIMARY KEY (id),
  CONSTRAINT completed_workout_sets_completed_workout_exercise_id_fkey FOREIGN KEY (completed_workout_exercise_id) REFERENCES public.completed_workout_exercises(id)
);
CREATE TABLE public.completed_workouts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  original_workout_id uuid,
  workout_name character varying NOT NULL,
  workout_icon_url text,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone NOT NULL,
  duration_seconds integer NOT NULL,
  intensity_score double precision NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone,
  CONSTRAINT completed_workouts_pkey PRIMARY KEY (id),
  CONSTRAINT completed_workouts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT completed_workouts_original_workout_id_fkey FOREIGN KEY (original_workout_id) REFERENCES public.workouts(id)
);
CREATE TABLE public.diet_recommendations (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  recommendation_text text NOT NULL,
  recommended_by character varying,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  CONSTRAINT diet_recommendations_pkey PRIMARY KEY (id),
  CONSTRAINT diet_recommendations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.discount_codes (
  id integer NOT NULL DEFAULT nextval('discount_codes_id_seq'::regclass),
  code character varying NOT NULL UNIQUE,
  description text,
  discount_type character varying CHECK (discount_type::text = ANY (ARRAY['percentage'::character varying, 'fixed_amount'::character varying]::text[])),
  discount_value numeric NOT NULL CHECK (discount_value > 0::numeric),
  minimum_order_amount numeric DEFAULT 0,
  maximum_discount_amount numeric,
  usage_limit integer CHECK (usage_limit IS NULL OR usage_limit > 0),
  used_count integer DEFAULT 0 CHECK (used_count >= 0),
  is_active boolean DEFAULT true,
  valid_from timestamp with time zone DEFAULT now(),
  valid_until timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discount_codes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.equipment_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  category character varying,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT equipment_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.exercise_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  description text,
  color_code character varying,
  icon_name character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exercise_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.exercise_equipment (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  exercise_id uuid,
  equipment_id uuid,
  is_required boolean DEFAULT true,
  is_alternative boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exercise_equipment_pkey PRIMARY KEY (id),
  CONSTRAINT exercise_equipment_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercise_library(id),
  CONSTRAINT exercise_equipment_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment_types(id)
);
-- Alter Table: posts
ALTER TABLE posts
ADD COLUMN privacy privacy_type_enum NOT NULL DEFAULT 'public';

-- Table: community_posts (Link posts to communities)
CREATE TABLE IF NOT EXISTS community_posts (
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (community_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_community_posts_community_id ON community_posts(community_id);
CREATE INDEX IF NOT EXISTS idx_community_posts_post_id ON community_posts(post_id);

-- Table: post_comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()

CREATE TABLE public.exercise_library (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  description text,
  instructions text,
  form_tips text,
  gif_url text,
  video_url text,
  category_id uuid,
  difficulty_level integer CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
  popularity_score numeric DEFAULT 0.0,
  is_compound boolean DEFAULT false,
  is_unilateral boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  search_vector tsvector DEFAULT to_tsvector('english'::regconfig, (((((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(instructions, ''::text))),
  CONSTRAINT exercise_library_pkey PRIMARY KEY (id),
  CONSTRAINT exercise_library_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.exercise_categories(id)
);
CREATE TABLE public.exercise_muscle_groups (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  exercise_id uuid,
  muscle_group_id uuid,
  is_primary boolean DEFAULT true,
  activation_level integer CHECK (activation_level >= 1 AND activation_level <= 5),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exercise_muscle_groups_pkey PRIMARY KEY (id),
  CONSTRAINT exercise_muscle_groups_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercise_library(id),
  CONSTRAINT exercise_muscle_groups_muscle_group_id_fkey FOREIGN KEY (muscle_group_id) REFERENCES public.muscle_groups(id)
);
CREATE TABLE public.exercise_variations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  base_exercise_id uuid,
  variation_exercise_id uuid,
  variation_type character varying,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exercise_variations_pkey PRIMARY KEY (id),
  CONSTRAINT exercise_variations_base_exercise_id_fkey FOREIGN KEY (base_exercise_id) REFERENCES public.exercise_library(id),
  CONSTRAINT exercise_variations_variation_exercise_id_fkey FOREIGN KEY (variation_exercise_id) REFERENCES public.exercise_library(id)
);
CREATE TABLE public.exercises (
  id uuid NOT NULL,
  name text NOT NULL,
  gifUrl text NOT NULL,
  bodyParts text,
  equipments text,
  sets integer,
  reps integer,
  weight double precision,
  duration_seconds integer,
  notes text,
  order_in_workout integer,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  exercise_library_id uuid,
  CONSTRAINT exercises_pkey PRIMARY KEY (id),
  CONSTRAINT exercises_exercise_library_id_fkey FOREIGN KEY (exercise_library_id) REFERENCES public.exercise_library(id)
);
CREATE TABLE public.food_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  meal_id uuid NOT NULL,
  name character varying NOT NULL,
  calories double precision NOT NULL,
  protein double precision NOT NULL,
  carbs double precision NOT NULL,
  fat double precision NOT NULL,
  quantity double precision NOT NULL DEFAULT 1.0,
  unit character varying NOT NULL DEFAULT 'item'::character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT food_items_pkey PRIMARY KEY (id),
  CONSTRAINT food_items_meal_id_fkey FOREIGN KEY (meal_id) REFERENCES public.meals(id)
);
CREATE TABLE public.food_logs (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  log_date timestamp with time zone NOT NULL,
  meal_type character varying NOT NULL,
  calories integer,
  protein_g double precision,
  carbs_g double precision,
  fat_g double precision,
  notes text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  food_name text NOT NULL DEFAULT '''N/A'''::text,
  external_food_id character varying,
  serving_size character varying,
  CONSTRAINT food_logs_pkey PRIMARY KEY (id),
  CONSTRAINT food_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.gym_buddies (
  user_id uuid NOT NULL,
  buddy_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  relations USER-DEFINED,
  CONSTRAINT gym_buddies_pkey PRIMARY KEY (buddy_id, user_id),
  CONSTRAINT gym_buddies_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT gym_buddies_buddy_id_fkey FOREIGN KEY (buddy_id) REFERENCES public.users(id)
);
CREATE TABLE public.health_logs (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  log_date timestamp with time zone NOT NULL,
  weight_kg double precision,
  sleep_hours double precision,
  mood_score integer,
  notes text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  log_type text NOT NULL DEFAULT ''::text,
  water_intake_ml double precision DEFAULT '0'::double precision,
  value double precision NOT NULL,
  CONSTRAINT health_logs_pkey PRIMARY KEY (id),
  CONSTRAINT health_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.meal_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  user_goals text,
  linked_workout_plan_id uuid,
  meals_json jsonb NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT meal_plans_pkey PRIMARY KEY (id),
  CONSTRAINT meal_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT meal_plans_linked_workout_plan_id_fkey FOREIGN KEY (linked_workout_plan_id) REFERENCES public.workouts(id)
);
CREATE TABLE public.meals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  meal_type character varying NOT NULL,
  logged_at timestamp with time zone NOT NULL DEFAULT now(),
  total_calories double precision NOT NULL,
  total_protein double precision NOT NULL,
  total_carbs double precision NOT NULL,
  total_fat double precision NOT NULL,
  image_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT meals_pkey PRIMARY KEY (id),
  CONSTRAINT meals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.muscle_groups (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  group_type character varying NOT NULL CHECK (group_type::text = ANY (ARRAY['primary'::character varying, 'secondary'::character varying, 'stabilizer'::character varying]::text[])),
  parent_id uuid,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT muscle_groups_pkey PRIMARY KEY (id),
  CONSTRAINT muscle_groups_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.muscle_groups(id)
);
CREATE TABLE public.order_items (
  id integer NOT NULL DEFAULT nextval('order_items_id_seq'::regclass),
  order_id integer NOT NULL,
  product_id integer NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  price numeric NOT NULL CHECK (price >= 0::numeric),
  total_price numeric DEFAULT ((quantity)::numeric * price),
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.orders (
  id integer NOT NULL DEFAULT nextval('orders_id_seq'::regclass),
  user_id uuid NOT NULL,
  order_number character varying NOT NULL UNIQUE,
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'confirmed'::character varying, 'processing'::character varying, 'shipped'::character varying, 'delivered'::character varying, 'cancelled'::character varying, 'refunded'::character varying]::text[])),
  total_amount numeric NOT NULL CHECK (total_amount >= 0::numeric),
  shipping_address jsonb NOT NULL,
  payment_method character varying,
  payment_status character varying DEFAULT 'pending'::character varying CHECK (payment_status::text = ANY (ARRAY['pending'::character varying, 'paid'::character varying, 'failed'::character varying, 'refunded'::character varying, 'cancelled'::character varying]::text[])),
  payment_reference character varying,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.password_reset_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  token character varying NOT NULL UNIQUE,
  expires_at timestamp with time zone NOT NULL,
  CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.planned_exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  workout_id uuid NOT NULL,
  exercise_id character varying NOT NULL,
  exercise_name character varying NOT NULL,
  exercise_equipments ARRAY,
  exercise_gif_url text,
  type character varying,
  planned_sets integer NOT NULL,
  planned_reps integer NOT NULL,
  planned_weight character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT planned_exercises_pkey PRIMARY KEY (id),
  CONSTRAINT planned_exercises_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id)
);
CREATE TABLE public.post_comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT post_comments_pkey PRIMARY KEY (id),
  CONSTRAINT post_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT post_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.post_media (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL,
  url text NOT NULL,
  media_type character varying DEFAULT 'image'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT post_media_pkey PRIMARY KEY (id),
  CONSTRAINT post_media_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id)
);
CREATE TABLE public.post_reacts (
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  react_type character varying NOT NULL,
  emoji character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT post_reacts_pkey PRIMARY KEY (post_id, user_id),
  CONSTRAINT post_reacts_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT post_reacts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  content text,
  media_url text,
  post_type ARRAY NOT NULL,
  workout_post_id uuid,
  challenge_post_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  report_count integer DEFAULT 0,
  privacy USER-DEFINED NOT NULL DEFAULT 'public'::post_privacy,
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT posts_workout_post_id_fkey FOREIGN KEY (workout_post_id) REFERENCES public.workout_posts(id),
  CONSTRAINT posts_challenge_post_id_fkey FOREIGN KEY (challenge_post_id) REFERENCES public.challenge_posts(id)
);
CREATE TABLE public.products (
  id character varying NOT NULL,
  name character varying NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  images ARRAY,
  category character varying NOT NULL,
  sub_category character varying,
  category_icon character varying,
  rating numeric,
  review_count integer,
  features ARRAY,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT products_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  display_name character varying,
  bio text,
  profile_picture_url text,
  fitness_goals text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  is_public boolean NOT NULL DEFAULT false,
  height_cm double precision,
  weight_kg double precision,
  age integer,
  gender text,
  available_equipments jsonb,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.refresh_tokens (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  token_hash text NOT NULL UNIQUE,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone,
  revoked_at timestamp with time zone,
  CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.reported_posts (
  reported_post_id uuid NOT NULL,
  reported_userid uuid NOT NULL,
  reportedby_userid uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  report_tags USER-DEFINED DEFAULT 'misinformation'::report_type_enum,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::report_status_enum,
  severity_level smallint DEFAULT '0'::smallint CHECK (severity_level <= 10 AND severity_level >= 0),
  CONSTRAINT reported_posts_pkey PRIMARY KEY (reportedby_userid, reported_post_id),
  CONSTRAINT reported_posts_reported_post_id_fkey FOREIGN KEY (reported_post_id) REFERENCES public.posts(id),
  CONSTRAINT reported_posts_reported_userid_fkey FOREIGN KEY (reported_userid) REFERENCES public.users(id),
  CONSTRAINT reported_posts_reportedby_userid_fkey FOREIGN KEY (reportedby_userid) REFERENCES public.users(id)
);
CREATE TABLE public.reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL,
  target_type character varying NOT NULL,
  target_id uuid NOT NULL,
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  handled boolean DEFAULT false,
  CONSTRAINT reports_pkey PRIMARY KEY (id),
  CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(id)
);
CREATE TABLE public.ride_activities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  organizer_user_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  image_url text,
  distance_km double precision,
  elevation_meters integer,
  type USER-DEFINED NOT NULL,
  route_coordinates jsonb,
  location_name character varying,
  park_name character varying,
  start_time timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ride_activities_pkey PRIMARY KEY (id),
  CONSTRAINT ride_activities_organizer_user_id_fkey FOREIGN KEY (organizer_user_id) REFERENCES public.users(id)
);
CREATE TABLE public.ride_activity_participants (
  ride_activity_id uuid NOT NULL,
  user_id uuid NOT NULL,
  joined_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ride_activity_participants_pkey PRIMARY KEY (user_id, ride_activity_id),
  CONSTRAINT ride_activity_participants_ride_activity_id_fkey FOREIGN KEY (ride_activity_id) REFERENCES public.ride_activities(id),
  CONSTRAINT ride_activity_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.stories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name character varying NOT NULL,
  image text,
  is_your_story boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  visibility USER-DEFINED NOT NULL DEFAULT 'public'::post_privacy,
  CONSTRAINT stories_pkey PRIMARY KEY (id),
  CONSTRAINT stories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.story_content_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  story_id uuid NOT NULL,
  type character varying NOT NULL,
  content text NOT NULL,
  completed_workout_session text,
  gym_location text,
  time timestamp with time zone,
  location_details jsonb,
  workout_details jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT story_content_items_pkey PRIMARY KEY (id),
  CONSTRAINT story_content_items_story_id_fkey FOREIGN KEY (story_id) REFERENCES public.stories(id)
);
CREATE TABLE public.trainer_availabilities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainer_id uuid NOT NULL,
  weekday integer NOT NULL,
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trainer_availabilities_pkey PRIMARY KEY (id),
  CONSTRAINT trainer_availabilities_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.trainer_profiles(id)
);
CREATE TABLE public.trainer_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  bio text,
  certifications text,
  specialties text,
  rating double precision DEFAULT 0,
  hourly_rate double precision,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trainer_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT trainer_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.trainer_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainer_id uuid NOT NULL,
  user_id uuid NOT NULL,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone NOT NULL,
  status character varying NOT NULL DEFAULT 'pending'::character varying,
  notes text,
  price double precision,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trainer_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT trainer_sessions_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.trainer_profiles(id),
  CONSTRAINT trainer_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.training_plan_workouts (
  training_plan_id uuid NOT NULL,
  workout_id uuid NOT NULL,
  order_num integer NOT NULL,
  CONSTRAINT training_plan_workouts_pkey PRIMARY KEY (training_plan_id, workout_id),
  CONSTRAINT training_plan_workouts_training_plan_id_fkey FOREIGN KEY (training_plan_id) REFERENCES public.training_plans(id),
  CONSTRAINT training_plan_workouts_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id)
);
CREATE TABLE public.training_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainer_id uuid NOT NULL,
  title character varying NOT NULL,
  description text,
  price numeric,
  visibility USER-DEFINED NOT NULL DEFAULT 'public'::plan_visibility_enum,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT training_plans_pkey PRIMARY KEY (id),
  CONSTRAINT training_plans_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_locations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  location USER-DEFINED,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_locations_pkey PRIMARY KEY (id),
  CONSTRAINT user_locations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_training_plans (
  user_id uuid NOT NULL,
  training_plan_id uuid NOT NULL,
  purchased_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_training_plans_pkey PRIMARY KEY (user_id, training_plan_id),
  CONSTRAINT user_training_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_training_plans_training_plan_id_fkey FOREIGN KEY (training_plan_id) REFERENCES public.training_plans(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  username character varying NOT NULL UNIQUE,
  email character varying NOT NULL UNIQUE,
  password_hash text,
  role USER-DEFINED NOT NULL DEFAULT 'user'::user_role_enum,
  google_id character varying UNIQUE,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  status character varying NOT NULL DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'suspended'::character varying]::text[])),
  phone_no character varying CHECK (phone_no::text ~ '^\d{11}$'::text),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE TABLE public.wishlists (
  id integer NOT NULL DEFAULT nextval('wishlists_id_seq'::regclass),
  user_id uuid NOT NULL,
  product_id integer NOT NULL,
  added_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wishlists_pkey PRIMARY KEY (id),
  CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.workout_history (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  original_workout_id uuid,
  workout_name text NOT NULL,
  workout_icon_url text,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone NOT NULL,
  duration_seconds integer NOT NULL,
  intensity_score double precision NOT NULL,
  created_at timestamp with time zone,
  CONSTRAINT workout_history_pkey PRIMARY KEY (id),
  CONSTRAINT workout_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT workout_history_original_workout_id_fkey FOREIGN KEY (original_workout_id) REFERENCES public.workouts(id)
);
CREATE TABLE public.workout_post_exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  workout_post_id uuid NOT NULL,
  exercise_id character varying NOT NULL,
  name character varying NOT NULL,
  gif_url text NOT NULL,
  body_parts ARRAY,
  equipments ARRAY,
  target_muscles ARRAY,
  secondary_muscles ARRAY,
  instructions ARRAY,
  image_url text,
  exercise_type character varying,
  keywords ARRAY,
  overview text,
  video_url text,
  exercise_tips ARRAY,
  variations ARRAY,
  related_exercise_ids ARRAY,
  sets character varying,
  reps character varying,
  weight character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT workout_post_exercises_pkey PRIMARY KEY (id),
  CONSTRAINT workout_post_exercises_workout_post_id_fkey FOREIGN KEY (workout_post_id) REFERENCES public.workout_posts(id)
);
CREATE TABLE public.workout_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  workout_type character varying NOT NULL,
  duration_minutes integer NOT NULL,
  calories_burned integer NOT NULL,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT workout_posts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.workout_sets (
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  weight double precision,
  reps integer,
  isCompleted boolean,
  CONSTRAINT workout_sets_pkey PRIMARY KEY (id),
  CONSTRAINT workout_sets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.workout_template_exercises (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  template_id uuid NOT NULL,
  exercise_id uuid NOT NULL,
  position integer NOT NULL DEFAULT 1,
  sets integer,
  reps text,
  rest_seconds integer,
  planned_weight text,
  notes text,
  CONSTRAINT workout_template_exercises_pkey PRIMARY KEY (id),
  CONSTRAINT workout_template_exercises_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.workout_templates(id)
);
CREATE TABLE public.workout_templates (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  author text,
  difficulty text,
  duration_minutes integer,
  description text,
  icon_url text,
  is_public boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT workout_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.workouts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  icon_url text,
  equipment_selected text,
  one_rm_goal text,
  type character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid,
  description text DEFAULT '""'::text,
  prompt jsonb,
  CONSTRAINT workouts_pkey PRIMARY KEY (id),
  CONSTRAINT workouts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
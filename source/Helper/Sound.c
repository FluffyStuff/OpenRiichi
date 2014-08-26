/* Sound.c generated by valac 0.16.1, the Vala compiler
 * generated from Sound.vala, do not modify */


#include <glib.h>
#include <glib-object.h>
#include <SDL2/SDL_mixer.h>
#include <gee.h>
#include <stdlib.h>
#include <string.h>
#include <gobject/gvaluecollector.h>


#define TYPE_SOUND (sound_get_type ())
#define SOUND(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_SOUND, Sound))
#define SOUND_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_SOUND, SoundClass))
#define IS_SOUND(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_SOUND))
#define IS_SOUND_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_SOUND))
#define SOUND_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_SOUND, SoundClass))

typedef struct _Sound Sound;
typedef struct _SoundClass SoundClass;
typedef struct _SoundPrivate SoundPrivate;
#define _Mix_FreeMusic0(var) ((var == NULL) ? NULL : (var = (Mix_FreeMusic (var), NULL)))
#define _Mix_FreeChunk0(var) ((var == NULL) ? NULL : (var = (Mix_FreeChunk (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))
#define _sound_unref0(var) ((var == NULL) ? NULL : (var = (sound_unref (var), NULL)))
typedef struct _ParamSpecSound ParamSpecSound;

struct _Sound {
	GTypeInstance parent_instance;
	volatile int ref_count;
	SoundPrivate * priv;
	Mix_Music* _music;
	Mix_Chunk* _chunk;
};

struct _SoundClass {
	GTypeClass parent_class;
	void (*finalize) (Sound *self);
};

struct _ParamSpecSound {
	GParamSpec parent_instance;
};


static gpointer sound_parent_class = NULL;
static gboolean sound_initialized;
static gboolean sound_initialized = FALSE;
static GeeArrayList* sound_list;
static GeeArrayList* sound_list = NULL;

gpointer sound_ref (gpointer instance);
void sound_unref (gpointer instance);
GParamSpec* param_spec_sound (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void value_set_sound (GValue* value, gpointer v_object);
void value_take_sound (GValue* value, gpointer v_object);
gpointer value_get_sound (const GValue* value);
GType sound_get_type (void) G_GNUC_CONST;
enum  {
	SOUND_DUMMY_PROPERTY
};
#define SOUND_SOUND_ENABLED FALSE
gboolean sound_init (void);
void sound_quit (void);
Sound* sound_load_sound (const gchar* n);
static Sound* sound_new (const gchar* name);
static Sound* sound_construct (GType object_type, const gchar* name);
void sound_play_sound (const gchar* name);
Mix_Chunk* sound_get_chunk (Sound* self);
Mix_Music* sound_get_music (Sound* self);
static void sound_finalize (Sound* obj);


gboolean sound_init (void) {
	gboolean result = FALSE;
	gboolean _tmp0_;
	gint _tmp1_ = 0;
	gboolean success;
	gboolean _tmp2_;
#line 18 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = sound_initialized;
#line 18 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (_tmp0_) {
#line 19 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		result = TRUE;
#line 19 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		return result;
#line 91 "Sound.c"
	}
#line 21 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp1_ = Mix_OpenAudio (44100, (guint16) 0x8010, 2, 1024);
#line 21 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	success = _tmp1_ <= 0;
#line 22 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp2_ = success;
#line 22 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (_tmp2_) {
#line 23 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		sound_initialized = TRUE;
#line 103 "Sound.c"
	}
#line 24 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	result = success;
#line 24 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return result;
#line 109 "Sound.c"
}


void sound_quit (void) {
	gboolean _tmp0_;
#line 29 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = sound_initialized;
#line 29 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (_tmp0_) {
#line 31 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		Mix_CloseAudio ();
#line 32 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		sound_initialized = FALSE;
#line 123 "Sound.c"
	}
}


Sound* sound_load_sound (const gchar* n) {
	Sound* result = NULL;
	const gchar* _tmp0_;
	gchar* _tmp1_;
	gchar* _tmp2_;
	gchar* _tmp3_;
	gchar* _tmp4_;
	gchar* name;
	Sound* _tmp5_;
	Sound* sound;
	GeeArrayList* _tmp6_;
#line 36 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_val_if_fail (n != NULL, NULL);
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = n;
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp1_ = g_strconcat ("sounds/", _tmp0_, NULL);
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp2_ = _tmp1_;
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp3_ = g_strconcat (_tmp2_, ".wav", NULL);
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp4_ = _tmp3_;
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_g_free0 (_tmp2_);
#line 38 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	name = _tmp4_;
#line 39 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp5_ = sound_new (name);
#line 39 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	sound = _tmp5_;
#line 40 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp6_ = sound_list;
#line 40 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	gee_abstract_collection_add ((GeeAbstractCollection*) _tmp6_, sound);
#line 41 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	result = sound;
#line 41 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_g_free0 (name);
#line 41 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return result;
#line 169 "Sound.c"
}


void sound_play_sound (const gchar* name) {
	const gchar* _tmp0_;
	Sound* _tmp1_ = NULL;
	Sound* sound;
#line 44 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_if_fail (name != NULL);
#line 46 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = name;
#line 46 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp1_ = sound_load_sound (_tmp0_);
#line 46 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	sound = _tmp1_;
#line 48 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (SOUND_SOUND_ENABLED) {
#line 187 "Sound.c"
		Sound* _tmp2_;
		Mix_Chunk* _tmp3_;
		Mix_Chunk* _tmp4_;
#line 49 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		_tmp2_ = sound;
#line 49 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		_tmp3_ = sound_get_chunk (_tmp2_);
#line 49 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		_tmp4_ = _tmp3_;
#line 49 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		Mix_PlayChannelTimed ((gint) -1, _tmp4_, 0, -1);
#line 199 "Sound.c"
	}
#line 44 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_sound_unref0 (sound);
#line 203 "Sound.c"
}


static Sound* sound_construct (GType object_type, const gchar* name) {
	Sound* self = NULL;
	const gchar* _tmp0_;
	Mix_Chunk* _tmp1_;
#line 57 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_val_if_fail (name != NULL, NULL);
#line 57 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	self = (Sound*) g_type_create_instance (object_type);
#line 60 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = name;
#line 60 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp1_ = Mix_LoadWAV (_tmp0_);
#line 60 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_Mix_FreeChunk0 (self->_chunk);
#line 60 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	self->_chunk = _tmp1_;
#line 57 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return self;
#line 225 "Sound.c"
}


static Sound* sound_new (const gchar* name) {
#line 57 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return sound_construct (TYPE_SOUND, name);
#line 232 "Sound.c"
}


Mix_Music* sound_get_music (Sound* self) {
	Mix_Music* result;
	Mix_Music* _tmp0_;
#line 63 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_val_if_fail (self != NULL, NULL);
#line 63 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = self->_music;
#line 63 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	result = _tmp0_;
#line 63 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return result;
#line 247 "Sound.c"
}


Mix_Chunk* sound_get_chunk (Sound* self) {
	Mix_Chunk* result;
	Mix_Chunk* _tmp0_;
#line 64 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_val_if_fail (self != NULL, NULL);
#line 64 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = self->_chunk;
#line 64 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	result = _tmp0_;
#line 64 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return result;
#line 262 "Sound.c"
}


static void value_sound_init (GValue* value) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	value->data[0].v_pointer = NULL;
#line 269 "Sound.c"
}


static void value_sound_free_value (GValue* value) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (value->data[0].v_pointer) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		sound_unref (value->data[0].v_pointer);
#line 278 "Sound.c"
	}
}


static void value_sound_copy_value (const GValue* src_value, GValue* dest_value) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (src_value->data[0].v_pointer) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		dest_value->data[0].v_pointer = sound_ref (src_value->data[0].v_pointer);
#line 288 "Sound.c"
	} else {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		dest_value->data[0].v_pointer = NULL;
#line 292 "Sound.c"
	}
}


static gpointer value_sound_peek_pointer (const GValue* value) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return value->data[0].v_pointer;
#line 300 "Sound.c"
}


static gchar* value_sound_collect_value (GValue* value, guint n_collect_values, GTypeCValue* collect_values, guint collect_flags) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (collect_values[0].v_pointer) {
#line 307 "Sound.c"
		Sound* object;
		object = collect_values[0].v_pointer;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		if (object->parent_instance.g_class == NULL) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
			return g_strconcat ("invalid unclassed object pointer for value type `", G_VALUE_TYPE_NAME (value), "'", NULL);
#line 314 "Sound.c"
		} else if (!g_value_type_compatible (G_TYPE_FROM_INSTANCE (object), G_VALUE_TYPE (value))) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
			return g_strconcat ("invalid object type `", g_type_name (G_TYPE_FROM_INSTANCE (object)), "' for value type `", G_VALUE_TYPE_NAME (value), "'", NULL);
#line 318 "Sound.c"
		}
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		value->data[0].v_pointer = sound_ref (object);
#line 322 "Sound.c"
	} else {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		value->data[0].v_pointer = NULL;
#line 326 "Sound.c"
	}
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return NULL;
#line 330 "Sound.c"
}


static gchar* value_sound_lcopy_value (const GValue* value, guint n_collect_values, GTypeCValue* collect_values, guint collect_flags) {
	Sound** object_p;
	object_p = collect_values[0].v_pointer;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (!object_p) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		return g_strdup_printf ("value location for `%s' passed as NULL", G_VALUE_TYPE_NAME (value));
#line 341 "Sound.c"
	}
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (!value->data[0].v_pointer) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		*object_p = NULL;
#line 347 "Sound.c"
	} else if (collect_flags & G_VALUE_NOCOPY_CONTENTS) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		*object_p = value->data[0].v_pointer;
#line 351 "Sound.c"
	} else {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		*object_p = sound_ref (value->data[0].v_pointer);
#line 355 "Sound.c"
	}
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return NULL;
#line 359 "Sound.c"
}


GParamSpec* param_spec_sound (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags) {
	ParamSpecSound* spec;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_val_if_fail (g_type_is_a (object_type, TYPE_SOUND), NULL);
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	spec = g_param_spec_internal (G_TYPE_PARAM_OBJECT, name, nick, blurb, flags);
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	G_PARAM_SPEC (spec)->value_type = object_type;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return G_PARAM_SPEC (spec);
#line 373 "Sound.c"
}


gpointer value_get_sound (const GValue* value) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_val_if_fail (G_TYPE_CHECK_VALUE_TYPE (value, TYPE_SOUND), NULL);
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return value->data[0].v_pointer;
#line 382 "Sound.c"
}


void value_set_sound (GValue* value, gpointer v_object) {
	Sound* old;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_if_fail (G_TYPE_CHECK_VALUE_TYPE (value, TYPE_SOUND));
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	old = value->data[0].v_pointer;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (v_object) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		g_return_if_fail (G_TYPE_CHECK_INSTANCE_TYPE (v_object, TYPE_SOUND));
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		g_return_if_fail (g_value_type_compatible (G_TYPE_FROM_INSTANCE (v_object), G_VALUE_TYPE (value)));
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		value->data[0].v_pointer = v_object;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		sound_ref (value->data[0].v_pointer);
#line 402 "Sound.c"
	} else {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		value->data[0].v_pointer = NULL;
#line 406 "Sound.c"
	}
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (old) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		sound_unref (old);
#line 412 "Sound.c"
	}
}


void value_take_sound (GValue* value, gpointer v_object) {
	Sound* old;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_return_if_fail (G_TYPE_CHECK_VALUE_TYPE (value, TYPE_SOUND));
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	old = value->data[0].v_pointer;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (v_object) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		g_return_if_fail (G_TYPE_CHECK_INSTANCE_TYPE (v_object, TYPE_SOUND));
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		g_return_if_fail (g_value_type_compatible (G_TYPE_FROM_INSTANCE (v_object), G_VALUE_TYPE (value)));
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		value->data[0].v_pointer = v_object;
#line 431 "Sound.c"
	} else {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		value->data[0].v_pointer = NULL;
#line 435 "Sound.c"
	}
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (old) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		sound_unref (old);
#line 441 "Sound.c"
	}
}


static void sound_class_init (SoundClass * klass) {
	GeeArrayList* _tmp0_;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	sound_parent_class = g_type_class_peek_parent (klass);
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	SOUND_CLASS (klass)->finalize = sound_finalize;
#line 14 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_tmp0_ = gee_array_list_new (TYPE_SOUND, (GBoxedCopyFunc) sound_ref, sound_unref, NULL);
#line 14 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	sound_list = _tmp0_;
#line 456 "Sound.c"
}


static void sound_instance_init (Sound * self) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	self->ref_count = 1;
#line 463 "Sound.c"
}


static void sound_finalize (Sound* obj) {
	Sound * self;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	self = SOUND (obj);
#line 53 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_Mix_FreeMusic0 (self->_music);
#line 54 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	_Mix_FreeChunk0 (self->_chunk);
#line 475 "Sound.c"
}


GType sound_get_type (void) {
	static volatile gsize sound_type_id__volatile = 0;
	if (g_once_init_enter (&sound_type_id__volatile)) {
		static const GTypeValueTable g_define_type_value_table = { value_sound_init, value_sound_free_value, value_sound_copy_value, value_sound_peek_pointer, "p", value_sound_collect_value, "p", value_sound_lcopy_value };
		static const GTypeInfo g_define_type_info = { sizeof (SoundClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) sound_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (Sound), 0, (GInstanceInitFunc) sound_instance_init, &g_define_type_value_table };
		static const GTypeFundamentalInfo g_define_type_fundamental_info = { (G_TYPE_FLAG_CLASSED | G_TYPE_FLAG_INSTANTIATABLE | G_TYPE_FLAG_DERIVABLE | G_TYPE_FLAG_DEEP_DERIVABLE) };
		GType sound_type_id;
		sound_type_id = g_type_register_fundamental (g_type_fundamental_next (), "Sound", &g_define_type_info, &g_define_type_fundamental_info, 0);
		g_once_init_leave (&sound_type_id__volatile, sound_type_id);
	}
	return sound_type_id__volatile;
}


gpointer sound_ref (gpointer instance) {
	Sound* self;
	self = instance;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	g_atomic_int_inc (&self->ref_count);
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	return instance;
#line 500 "Sound.c"
}


void sound_unref (gpointer instance) {
	Sound* self;
	self = instance;
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
	if (g_atomic_int_dec_and_test (&self->ref_count)) {
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		SOUND_GET_CLASS (self)->finalize (self);
#line 5 "/home/fluffy/RiichiMahjong/source/Helper/Sound.vala"
		g_type_free_instance ((GTypeInstance *) self);
#line 513 "Sound.c"
	}
}




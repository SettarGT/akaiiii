<script setup>
import { ref } from 'vue'
import { Form, Field, ErrorMessage } from 'vee-validate';
import * as yup from 'yup'
import moment from 'moment'

const onSubmit = (values) => {
    fetch("http://esx_identity/register", {
            method: "POST",
            body: JSON.stringify({
                firstname: values.firstname,
                lastname: values.lastname,
                dateofbirth: moment(values.dob).format("DD/MM/YYYY"),
                sex: values.gender,
                height: values.height,
            }),
        });
}

const schema = yup.object({
    firstname: yup.string().required('Ad tələb olunur').min(3, 'Ad ən azı 3 simvol olmalıdır'),
    lastname: yup.string().required('Soyad tələb olunur').min(3, 'Soyad ən azı 3 simvol olmalıdır'),
    dob: yup.date()
    .required('Doğum tarixi tələb olunur')
    .min(new Date("1900-01-01"), "Tarix çox erkəndir")
    .max(moment().subtract(1, 'years').toDate(), "Ən azı 1 yaşında olmalısınız"),
    gender: yup.string().required('Cins tələb olunur'),
    height: yup.number().required('Boy tələb olunur').min(120, 'Minimum boy 120 sm-dir').max(220, 'Maksimum boy 220 sm-dir').typeError('Rəqəm daxil edin'),
})

</script>

<template>
    <div class="dialog">
        <div class="dialog__header">
            <h1>PERSONAJ <span>KİMLİK</span></h1>
        </div>
        <div class="dialog__body">
            <p class="dialog__body-hint">Şəxsiyyətinizi yaratmaqla başlayın</p>
            <Form class="dialog__body-form" id="register" action="#" novalidate @submit="onSubmit" :validation-schema="schema">
                <div class="dialog__form-group">
                    <label for="firstname">Ad</label>
                    <div class="dialog__form-validation">
                        <Field id="firstname" type="text" name="firstname" placeholder="Ad" validateOnInput />
                    </div>
                    <ErrorMessage name="firstname" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="lastname">Soyad</label>
                    <div class="dialog__form-validation">
                        <Field id="lastname" type="text" name="lastname" placeholder="Soyad" validateOnInput />
                    </div>
                    <ErrorMessage name="lastname" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="dob">Doğum tarixi</label>
                    <Field id="dob" type="date" name="dob" placeholder="gg/aa/yyyy" validateOnInput />
                    <ErrorMessage name="dob" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="gender">Cins</label>
                    <div class="dialog__form-group dialog__form-group--radio">
                        <div class="dialog__form-radio">
                            <Field type="radio" id="male" value="m" name="gender" validateOnInput />
                            <label for="male">
                                <i class="fas fa-mars"></i>Kişi
                            </label>
                        </div>
                        <div class="dialog__form-radio">
                            <Field type="radio" id="female" value="f" name="gender" validateOnInput />
                            <label for="female">
                                <i class="fas fa-venus"></i>Qadın
                            </label>
                        </div>
                    </div>
                    <ErrorMessage name="gender" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="height">Boy</label>
                    <Field id="height" type="text" name="height" placeholder="175" validateOnInput/>
                    <ErrorMessage name="height" class="dialog__form-message dialog__form-message--error" />
                </div>
                <button class="dialog__form-submit" id="submit" type="submit">
                    <i class="fas fa-user-plus"></i>YARAT
                </button>
            </Form>
        </div>
    </div>
</template>

<style scoped>
</style>

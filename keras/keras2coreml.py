import coremltools

output_labels = [line.rstrip('\n') for line in open('keras_labels.txt')]

scale = 1/255.
coreml_model = coremltools.converters.keras.convert('./adidas-CNN.h5',
                                                    input_names='image',
                                                    image_input_names='image',
                                                    output_names='output',
                                                    class_labels=output_labels,
                                                    image_scale=scale)

coreml_model.author = 'Rafael Marcen'
coreml_model.license = 'MIT'
coreml_model.short_description = ''
coreml_model.input_description['image'] = 'Input image'
coreml_model.output_description['output'] = 'Output'

coreml_model.save('../mobile-challenge/mobile-challenge/Models/adidasCNN.mlmodel')